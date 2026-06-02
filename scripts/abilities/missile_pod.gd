extends Node2D

const RuntimeQuery = preload("res://scripts/core/runtime_query.gd")

const BASE_INTERVAL: float = 4.4
const INTERVAL_STEP: float = 0.24
const MIN_INTERVAL: float = 1.4
const TARGET_RANGE: float = 580.0
const BASE_RADIUS: float = 42.0
const RADIUS_PER_LEVEL: float = 3.0
const DAMAGE_MULTIPLIER: float = 0.7
const VISUAL_LIFETIME: float = 0.22

var player: CharacterBody2D
var missile_level: int = 1
var fire_timer: float = 0.0
var visual_timer: float = 0.0
var visual_targets: Array[Vector2] = []


func _process(delta: float) -> void:
	if player == null or player.is_dead:
		queue_free()
		return
	
	global_position = player.global_position
	fire_timer += delta
	if fire_timer >= get_interval():
		fire_timer = 0.0
		fire_missiles()
	
	visual_timer = max(visual_timer - delta, 0.0)
	if visual_timer > 0.0:
		queue_redraw()


func configure(new_player: CharacterBody2D, new_level: int) -> void:
	player = new_player
	missile_level = max(new_level, 1)
	fire_timer = randf_range(0.0, get_interval() * 0.45)


func update_level(new_level: int) -> void:
	missile_level = max(new_level, 1)


func get_interval() -> float:
	return max(BASE_INTERVAL - float(missile_level - 1) * INTERVAL_STEP, MIN_INTERVAL)


func get_missile_count() -> int:
	return mini(2 + int(floor(float(missile_level) / 2.0)), 8)


func get_radius() -> float:
	return BASE_RADIUS + float(missile_level - 1) * RADIUS_PER_LEVEL


func fire_missiles() -> void:
	var targets := get_targets()
	if targets.is_empty():
		return
	
	visual_targets.clear()
	var main := get_tree().current_scene
	for target in targets:
		if not is_instance_valid(target):
			continue
		visual_targets.append(target.global_position)
		if main and main.has_method("_spawn_splash_area"):
			main._spawn_splash_area(target.global_position, get_radius(), get_damage(), [target])
		elif target.has_method("hit"):
			var actual_damage: int = target.hit(get_damage())
			record_player_damage(actual_damage)
	
	if not visual_targets.is_empty():
		visual_timer = VISUAL_LIFETIME
		queue_redraw()


func get_targets() -> Array[Area2D]:
	var candidates: Array[Area2D] = []
	var range_squared := TARGET_RANGE * TARGET_RANGE
	for enemy in RuntimeQuery.get_active_enemies(self):
		if not is_instance_valid(enemy) or not enemy is Area2D:
			continue
		if enemy.has_method("is_damageable") and not enemy.is_damageable():
			continue
		if global_position.distance_squared_to(enemy.global_position) > range_squared:
			continue
		candidates.append(enemy)
	
	candidates.sort_custom(func(a: Area2D, b: Area2D) -> bool:
		return global_position.distance_squared_to(a.global_position) < global_position.distance_squared_to(b.global_position)
	)
	
	var picked: Array[Area2D] = []
	for i in range(mini(get_missile_count(), candidates.size())):
		picked.append(candidates[i])
	return picked


func get_damage() -> float:
	if player == null:
		return 0.0
	var multiplier := 1.0
	if player.has_method("get_area_damage_multiplier"):
		multiplier = player.get_area_damage_multiplier()
	if player.has_method("get_power_damage_multiplier"):
		multiplier *= player.get_power_damage_multiplier()
	return player.attack_damage * DAMAGE_MULTIPLIER * pow(1.11, float(missile_level - 1)) * multiplier


func record_player_damage(amount: int) -> void:
	if amount <= 0:
		return
	var main := get_tree().current_scene
	if main and main.has_method("record_player_damage"):
		main.record_player_damage(amount)


func _draw() -> void:
	if visual_timer <= 0.0:
		return
	var alpha := visual_timer / VISUAL_LIFETIME
	for target_position in visual_targets:
		draw_line(Vector2.ZERO, to_local(target_position), Color(1.0, 0.76, 0.18, alpha), 3.0, true)
		draw_circle(to_local(target_position), 8.0, Color(1.0, 0.34, 0.12, alpha * 0.42))
