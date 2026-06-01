extends Node2D

const BASE_RADIUS: float = 72.0
const RADIUS_PER_LEVEL: float = 7.0
const DAMAGE_INTERVAL: float = 0.55
const HEAL_INTERVAL: float = 5.4
const DAMAGE_MULTIPLIER: float = 0.16
const SLOW_DURATION: float = 0.28
const SLOW_MULTIPLIER: float = 0.86

var player: CharacterBody2D
var cloud_level: int = 1
var damage_timer: float = 0.0
var heal_timer: float = 0.0
var pulse_time: float = 0.0


func _process(delta: float) -> void:
	if player == null or player.is_dead:
		queue_free()
		return
	
	global_position = player.global_position
	pulse_time += delta
	damage_timer += delta
	heal_timer += delta
	if damage_timer >= DAMAGE_INTERVAL:
		damage_timer = 0.0
		damage_enemies()
	if heal_timer >= get_heal_interval():
		heal_timer = 0.0
		repair_player()
	queue_redraw()


func configure(new_player: CharacterBody2D, new_level: int) -> void:
	player = new_player
	cloud_level = max(new_level, 1)
	damage_timer = randf_range(0.0, DAMAGE_INTERVAL)
	heal_timer = randf_range(0.0, get_heal_interval() * 0.45)


func update_level(new_level: int) -> void:
	cloud_level = max(new_level, 1)


func get_radius() -> float:
	return BASE_RADIUS + float(cloud_level - 1) * RADIUS_PER_LEVEL


func get_heal_interval() -> float:
	return max(HEAL_INTERVAL - float(cloud_level - 1) * 0.22, 2.0)


func damage_enemies() -> void:
	var radius_squared := get_radius() * get_radius()
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		if not is_instance_valid(enemy):
			continue
		if enemy.has_method("is_damageable") and not enemy.is_damageable():
			continue
		if global_position.distance_squared_to(enemy.global_position) > radius_squared:
			continue
		if enemy.has_method("apply_slow"):
			enemy.apply_slow(SLOW_DURATION, SLOW_MULTIPLIER)
		if enemy.has_method("hit"):
			var actual_damage: int = enemy.hit(get_damage())
			record_player_damage(actual_damage)


func repair_player() -> void:
	if player == null or not player.has_method("heal"):
		return
	var healed_amount: int = player.heal(1 + int(floor(float(cloud_level) / 4.0)))
	var main := get_tree().current_scene
	if healed_amount > 0 and main and main.has_method("show_healing_popup"):
		main.show_healing_popup(player.global_position + Vector2(0.0, -30.0), healed_amount)


func get_damage() -> float:
	if player == null:
		return 0.0
	var multiplier := 1.0
	if player.has_method("get_power_damage_multiplier"):
		multiplier = player.get_power_damage_multiplier()
	return player.attack_damage * DAMAGE_MULTIPLIER * float(cloud_level) * multiplier


func record_player_damage(amount: int) -> void:
	if amount <= 0:
		return
	var main := get_tree().current_scene
	if main and main.has_method("record_player_damage"):
		main.record_player_damage(amount)


func _draw() -> void:
	var pulse := 0.72 + sin(pulse_time * 4.0) * 0.18
	draw_circle(Vector2.ZERO, get_radius(), Color(0.34, 1.0, 0.76, 0.07 * pulse))
	draw_arc(Vector2.ZERO, get_radius() * pulse, 0.0, TAU, 72, Color(0.42, 1.0, 0.78, 0.32), 2.0, true)
