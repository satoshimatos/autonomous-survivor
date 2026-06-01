extends Node2D

const BASE_INTERVAL: float = 7.0
const INTERVAL_STEP: float = 0.34
const MIN_INTERVAL: float = 2.4
const BASE_RADIUS: float = 132.0
const RADIUS_PER_LEVEL: float = 13.0
const DAMAGE_MULTIPLIER: float = 0.42
const SLOW_DURATION: float = 1.45
const SLOW_MULTIPLIER: float = 0.24
const VISUAL_LIFETIME: float = 0.42

var player: CharacterBody2D
var chrono_level: int = 1
var burst_timer: float = 0.0
var visual_timer: float = 0.0


func _process(delta: float) -> void:
	if player == null or player.is_dead:
		queue_free()
		return
	
	global_position = player.global_position
	burst_timer += delta
	if burst_timer >= get_interval():
		burst_timer = 0.0
		visual_timer = VISUAL_LIFETIME
		apply_burst()
	
	visual_timer = max(visual_timer - delta, 0.0)
	if visual_timer > 0.0:
		queue_redraw()


func configure(new_player: CharacterBody2D, new_level: int) -> void:
	player = new_player
	chrono_level = max(new_level, 1)
	burst_timer = randf_range(0.0, get_interval() * 0.5)


func update_level(new_level: int) -> void:
	chrono_level = max(new_level, 1)


func get_interval() -> float:
	return max(BASE_INTERVAL - float(chrono_level - 1) * INTERVAL_STEP, MIN_INTERVAL)


func get_radius() -> float:
	return BASE_RADIUS + float(chrono_level - 1) * RADIUS_PER_LEVEL


func apply_burst() -> void:
	var radius_squared := get_radius() * get_radius()
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		if not is_instance_valid(enemy):
			continue
		if enemy.has_method("is_damageable") and not enemy.is_damageable():
			continue
		if global_position.distance_squared_to(enemy.global_position) > radius_squared:
			continue
		if enemy.has_method("apply_slow"):
			enemy.apply_slow(SLOW_DURATION + float(chrono_level) * 0.08, SLOW_MULTIPLIER)
		if enemy.has_method("hit"):
			var actual_damage: int = enemy.hit(get_damage())
			record_player_damage(actual_damage)


func get_damage() -> float:
	if player == null:
		return 0.0
	var multiplier := 1.0
	if player.has_method("get_power_damage_multiplier"):
		multiplier = player.get_power_damage_multiplier()
	return player.attack_damage * DAMAGE_MULTIPLIER * pow(1.1, float(chrono_level - 1)) * multiplier


func record_player_damage(amount: int) -> void:
	if amount <= 0:
		return
	var main := get_tree().current_scene
	if main and main.has_method("record_player_damage"):
		main.record_player_damage(amount)


func _draw() -> void:
	if visual_timer <= 0.0:
		return
	var progress: float = 1.0 - visual_timer / VISUAL_LIFETIME
	var radius: float = lerp(16.0, get_radius(), ease(progress, -1.25))
	var alpha: float = 0.62 * (1.0 - progress)
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 96, Color(0.78, 0.62, 1.0, alpha), 5.0, true)
	draw_arc(Vector2.ZERO, radius * 0.52, 0.0, TAU, 96, Color(0.38, 0.86, 1.0, alpha * 0.55), 2.0, true)
