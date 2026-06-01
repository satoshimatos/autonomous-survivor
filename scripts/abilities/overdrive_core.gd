extends Node2D

const BASE_DAMAGE_BONUS: float = 0.08
const DAMAGE_BONUS_PER_LEVEL: float = 0.035
const BASE_SPEED_BONUS: float = 0.04
const SPEED_BONUS_PER_LEVEL: float = 0.015
const BASE_RADIUS: float = 42.0
const RADIUS_STEP: float = 5.0

var player: CharacterBody2D
var overdrive_level: int = 1
var pulse_timer: float = 0.0


func _process(delta: float) -> void:
	if player == null or player.is_dead:
		queue_free()
		return
	
	global_position = player.global_position
	pulse_timer += delta
	queue_redraw()


func configure(new_player: CharacterBody2D, new_level: int) -> void:
	player = new_player
	overdrive_level = max(new_level, 1)


func update_level(new_level: int) -> void:
	overdrive_level = max(new_level, 1)


func get_damage_multiplier() -> float:
	return 1.0 + BASE_DAMAGE_BONUS + float(overdrive_level - 1) * DAMAGE_BONUS_PER_LEVEL


func get_speed_multiplier() -> float:
	return 1.0 + BASE_SPEED_BONUS + float(overdrive_level - 1) * SPEED_BONUS_PER_LEVEL


func get_radius() -> float:
	return BASE_RADIUS + float(overdrive_level - 1) * RADIUS_STEP


func _draw() -> void:
	var pulse := 0.65 + sin(pulse_timer * 5.0) * 0.2
	draw_arc(Vector2.ZERO, get_radius(), 0.0, TAU, 64, Color(1.0, 0.34, 0.12, 0.45 * pulse), 3.0, true)
	draw_arc(Vector2.ZERO, get_radius() * 0.72, 0.0, TAU, 64, Color(1.0, 0.78, 0.18, 0.26 * pulse), 2.0, true)
