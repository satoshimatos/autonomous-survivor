extends Node2D

const RuntimeQuery = preload("res://scripts/core/runtime_query.gd")

const BASE_INTERVAL: float = 6.5
const INTERVAL_STEP: float = 0.28
const MIN_INTERVAL: float = 2.8
const BASE_RADIUS: float = 88.0
const RADIUS_PER_LEVEL: float = 8.0
const DAMAGE_MULTIPLIER: float = 0.18
const SLOW_DURATION: float = 0.35
const SLOW_MULTIPLIER: float = 0.82
const VISUAL_LIFETIME: float = 0.45

var player: CharacterBody2D
var beacon_level: int = 1
var repair_timer: float = 0.0
var visual_timer: float = 0.0


func _process(delta: float) -> void:
	if player == null or player.is_dead:
		queue_free()
		return
	
	global_position = player.global_position
	repair_timer += delta
	if repair_timer >= get_interval():
		repair_timer = 0.0
		visual_timer = VISUAL_LIFETIME
		activate_beacon()
	
	visual_timer = max(visual_timer - delta, 0.0)
	if visual_timer > 0.0:
		queue_redraw()


func configure(new_player: CharacterBody2D, new_level: int) -> void:
	player = new_player
	beacon_level = max(new_level, 1)
	repair_timer = randf_range(0.0, get_interval() * 0.35)


func update_level(new_level: int) -> void:
	beacon_level = max(new_level, 1)


func get_interval() -> float:
	return max(BASE_INTERVAL - float(beacon_level - 1) * INTERVAL_STEP, MIN_INTERVAL)


func get_radius() -> float:
	return BASE_RADIUS + float(beacon_level - 1) * RADIUS_PER_LEVEL


func activate_beacon() -> void:
	if player.has_method("heal"):
		var healed_amount: int = player.heal(1 + int(floor(float(beacon_level) / 3.0)))
		var main := get_tree().current_scene
		if healed_amount > 0 and main and main.has_method("show_healing_popup"):
			main.show_healing_popup(player.global_position + Vector2(0.0, -24.0), healed_amount)
	
	var radius := get_radius()
	var radius_squared := radius * radius
	for enemy in RuntimeQuery.get_active_enemies(self):
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


func get_damage() -> float:
	if player == null:
		return 0.0
	var multiplier := 1.0
	if player.has_method("get_power_damage_multiplier"):
		multiplier = player.get_power_damage_multiplier()
	return player.attack_damage * DAMAGE_MULTIPLIER * float(beacon_level) * multiplier


func record_player_damage(amount: int) -> void:
	if amount <= 0:
		return
	var main := get_tree().current_scene
	if main and main.has_method("record_player_damage"):
		main.record_player_damage(amount)


func _draw() -> void:
	var pulse := 0.68 + sin(Time.get_ticks_msec() * 0.006) * 0.16
	draw_arc(Vector2.ZERO, get_radius(), 0.0, TAU, 72, Color(0.3, 1.0, 0.58, 0.22 * pulse), 2.0, true)
	if visual_timer <= 0.0:
		return
	var alpha: float = visual_timer / VISUAL_LIFETIME
	draw_circle(Vector2.ZERO, get_radius(), Color(0.28, 1.0, 0.64, 0.08 * alpha))
	draw_arc(Vector2.ZERO, get_radius() * (1.0 - alpha * 0.35), 0.0, TAU, 72, Color(0.72, 1.0, 0.82, 0.48 * alpha), 4.0, true)
