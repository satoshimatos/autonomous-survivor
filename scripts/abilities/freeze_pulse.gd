extends Node2D

const BASE_INTERVAL: float = 6.0
const INTERVAL_STEP: float = 0.42
const MIN_INTERVAL: float = 2.0
const BASE_RADIUS: float = 120.0
const RADIUS_PER_LEVEL: float = 15.0
const DAMAGE_MULTIPLIER: float = 0.58
const FREEZE_DURATION: float = 1.25
const FREEZE_MULTIPLIER: float = 0.16
const VISUAL_LIFETIME: float = 0.32

var player: CharacterBody2D
var freeze_level: int = 1
var pulse_timer: float = 0.0
var visual_timer: float = 0.0


func _process(delta: float) -> void:
	if player == null or player.is_dead:
		queue_free()
		return
	
	global_position = player.global_position
	pulse_timer += delta
	if pulse_timer >= get_interval():
		pulse_timer = 0.0
		visual_timer = VISUAL_LIFETIME
		apply_freeze()
	
	visual_timer = max(visual_timer - delta, 0.0)
	if visual_timer > 0.0:
		queue_redraw()


func configure(new_player: CharacterBody2D, new_level: int) -> void:
	player = new_player
	freeze_level = max(new_level, 1)
	pulse_timer = randf_range(0.0, get_interval() * 0.4)


func update_level(new_level: int) -> void:
	freeze_level = max(new_level, 1)


func get_interval() -> float:
	return max(BASE_INTERVAL - float(freeze_level - 1) * INTERVAL_STEP, MIN_INTERVAL)


func get_radius() -> float:
	return BASE_RADIUS + float(freeze_level - 1) * RADIUS_PER_LEVEL


func apply_freeze() -> void:
	var radius := get_radius()
	var radius_squared := radius * radius
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		if not is_instance_valid(enemy):
			continue
		if enemy.has_method("is_damageable") and not enemy.is_damageable():
			continue
		if global_position.distance_squared_to(enemy.global_position) > radius_squared:
			continue
		
		if enemy.has_method("apply_slow"):
			enemy.apply_slow(FREEZE_DURATION + float(freeze_level) * 0.08, FREEZE_MULTIPLIER)
		if enemy.has_method("hit"):
			var actual_damage: int = enemy.hit(get_damage())
			var main := get_tree().current_scene
			if actual_damage > 0 and main and main.has_method("record_player_damage"):
				main.record_player_damage(actual_damage)


func get_damage() -> float:
	if player == null:
		return 0.0
	return player.attack_damage * DAMAGE_MULTIPLIER * pow(1.12, float(freeze_level - 1))


func _draw() -> void:
	if visual_timer <= 0.0:
		return
	
	var progress: float = 1.0 - visual_timer / VISUAL_LIFETIME
	var radius: float = get_radius()
	var current_radius: float = lerp(12.0, radius, ease(progress, -1.5))
	var alpha: float = 0.72 * (1.0 - progress)
	draw_arc(Vector2.ZERO, current_radius, 0.0, TAU, 96, Color(0.62, 0.9, 1.0, alpha), 5.0, true)
	draw_circle(Vector2.ZERO, current_radius * 0.35, Color(0.55, 0.8, 1.0, alpha * 0.12))
