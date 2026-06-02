extends Node2D

const RuntimeQuery = preload("res://scripts/core/runtime_query.gd")

const BASE_RADIUS: float = 56.0
const RADIUS_PER_LEVEL: float = 7.0
const LIFETIME: float = 7.0
const DAMAGE_INTERVAL: float = 0.55
const DAMAGE_MULTIPLIER: float = 0.16
const SLOW_DURATION: float = 0.75
const SLOW_MULTIPLIER: float = 0.42

var player: CharacterBody2D
var oil_level: int = 1
var age: float = 0.0
var damage_timer: float = 0.0
var enemy_cooldowns := {}


func configure(new_player: CharacterBody2D, new_level: int) -> void:
	player = new_player
	oil_level = max(new_level, 1)


func _process(delta: float) -> void:
	age += delta
	damage_timer += delta
	update_cooldowns(delta)
	if damage_timer >= DAMAGE_INTERVAL:
		damage_timer -= DAMAGE_INTERVAL
		apply_oil_effect()
	
	if age >= LIFETIME:
		queue_free()
		return
	
	queue_redraw()


func get_radius() -> float:
	return BASE_RADIUS + float(oil_level - 1) * RADIUS_PER_LEVEL


func update_cooldowns(delta: float) -> void:
	for enemy in enemy_cooldowns.keys():
		if not is_instance_valid(enemy):
			enemy_cooldowns.erase(enemy)
			continue
		
		enemy_cooldowns[enemy] -= delta
		if float(enemy_cooldowns[enemy]) <= 0.0:
			enemy_cooldowns.erase(enemy)


func apply_oil_effect() -> void:
	var radius := get_radius()
	var radius_squared := radius * radius
	for enemy in RuntimeQuery.get_active_enemies(self):
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
	return player.attack_damage * DAMAGE_MULTIPLIER * float(oil_level)


func _draw() -> void:
	var progress: float = clamp(age / LIFETIME, 0.0, 1.0)
	var alpha: float = 0.36 * (1.0 - progress)
	var radius: float = get_radius()
	draw_circle(Vector2.ZERO, radius, Color(0.05, 0.05, 0.03, alpha))
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 64, Color(0.45, 0.42, 0.18, alpha + 0.12), 3.0, true)
