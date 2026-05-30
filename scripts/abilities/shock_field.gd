extends Node2D

const BASE_RADIUS: float = 78.0
const RADIUS_PER_LEVEL: float = 14.0
const DAMAGE_INTERVAL: float = 0.45
const DAMAGE_MULTIPLIER: float = 0.22
const SLOW_DURATION: float = 0.8
const SLOW_MULTIPLIER: float = 0.58

var player: CharacterBody2D
var shock_level: int = 1
var damage_timer: float = 0.0
var pulse_age: float = 0.0
var enemy_cooldowns := {}


func _process(delta: float) -> void:
	if player == null or player.is_dead:
		queue_free()
		return
	
	global_position = player.global_position
	damage_timer += delta
	pulse_age += delta
	update_cooldowns(delta)
	if damage_timer >= DAMAGE_INTERVAL:
		damage_timer -= DAMAGE_INTERVAL
		pulse_enemies()
	queue_redraw()


func configure(new_player: CharacterBody2D, new_level: int) -> void:
	player = new_player
	shock_level = max(new_level, 1)


func update_level(new_level: int) -> void:
	shock_level = max(new_level, 1)


func get_radius() -> float:
	return BASE_RADIUS + float(shock_level - 1) * RADIUS_PER_LEVEL


func update_cooldowns(delta: float) -> void:
	for enemy in enemy_cooldowns.keys():
		if not is_instance_valid(enemy):
			enemy_cooldowns.erase(enemy)
			continue
		
		enemy_cooldowns[enemy] -= delta
		if float(enemy_cooldowns[enemy]) <= 0.0:
			enemy_cooldowns.erase(enemy)


func pulse_enemies() -> void:
	var radius := get_radius()
	var radius_squared := radius * radius
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		if not is_instance_valid(enemy):
			continue
		if enemy_cooldowns.has(enemy):
			continue
		if enemy.has_method("is_damageable") and not enemy.is_damageable():
			continue
		if global_position.distance_squared_to(enemy.global_position) > radius_squared:
			continue
		
		enemy_cooldowns[enemy] = DAMAGE_INTERVAL
		if enemy.has_method("apply_slow"):
			enemy.apply_slow(SLOW_DURATION, SLOW_MULTIPLIER)
		if enemy.has_method("hit"):
			var actual_damage: int = enemy.hit(get_damage())
			var main := get_tree().current_scene
			if actual_damage > 0 and main and main.has_method("record_player_damage"):
				main.record_player_damage(actual_damage)


func get_damage() -> float:
	if player == null:
		return 0.0
	return player.attack_damage * DAMAGE_MULTIPLIER * float(shock_level)


func _draw() -> void:
	var radius := get_radius()
	var pulse := fmod(pulse_age, DAMAGE_INTERVAL) / DAMAGE_INTERVAL
	var alpha := 0.42 + sin(pulse_age * TAU * 2.0) * 0.08
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 96, Color(0.2, 0.85, 1.0, alpha), 3.0, true)
	draw_arc(Vector2.ZERO, radius * lerp(0.7, 1.0, pulse), 0.0, TAU, 96, Color(0.8, 1.0, 1.0, 0.28 * (1.0 - pulse)), 2.0, true)
