extends Node2D

const RuntimeQuery = preload("res://scripts/core/runtime_query.gd")

const BASE_INTERVAL: float = 4.0
const INTERVAL_STEP: float = 0.28
const MIN_INTERVAL: float = 1.4
const BASE_RADIUS: float = 82.0
const RADIUS_PER_LEVEL: float = 9.0
const DAMAGE_MULTIPLIER: float = 2.1
const TARGET_RANGE: float = 520.0
const TELEGRAPH_TIME: float = 0.55

var player: CharacterBody2D
var artillery_level: int = 1
var fire_timer: float = 0.0
var telegraph_timer: float = 0.0
var telegraph_position: Vector2 = Vector2.ZERO
var has_telegraph: bool = false


func _process(delta: float) -> void:
	if player == null or player.is_dead:
		queue_free()
		return
	
	if has_telegraph:
		telegraph_timer -= delta
		if telegraph_timer <= 0.0:
			strike_telegraph()
		queue_redraw()
		return
	
	fire_timer += delta
	if fire_timer >= get_interval():
		fire_timer = 0.0
		start_telegraph()
	queue_redraw()


func configure(new_player: CharacterBody2D, new_level: int) -> void:
	player = new_player
	artillery_level = max(new_level, 1)
	fire_timer = randf_range(0.0, get_interval() * 0.5)


func update_level(new_level: int) -> void:
	artillery_level = max(new_level, 1)


func get_interval() -> float:
	return max(BASE_INTERVAL - float(artillery_level - 1) * INTERVAL_STEP, MIN_INTERVAL)


func get_radius() -> float:
	return BASE_RADIUS + float(artillery_level - 1) * RADIUS_PER_LEVEL


func start_telegraph() -> void:
	var target := get_target_enemy()
	if target == null:
		return
	
	telegraph_position = target.global_position
	telegraph_timer = TELEGRAPH_TIME
	has_telegraph = true


func strike_telegraph() -> void:
	has_telegraph = false
	var main := get_tree().current_scene
	if main == null or not main.has_method("_spawn_splash_area"):
		return
	
	var enemies := get_enemies_in_radius(telegraph_position, get_radius())
	main.call_deferred("_spawn_splash_area", telegraph_position, get_radius(), get_damage(), enemies)


func get_target_enemy() -> Node2D:
	var candidates: Array[Node2D] = []
	var range_squared := TARGET_RANGE * TARGET_RANGE
	for enemy in RuntimeQuery.get_active_enemies(self):
		if not is_instance_valid(enemy):
			continue
		if enemy.has_method("is_damageable") and not enemy.is_damageable():
			continue
		if player.global_position.distance_squared_to(enemy.global_position) > range_squared:
			continue
		candidates.append(enemy)
	
	if candidates.is_empty():
		return null
	
	candidates.sort_custom(func(a: Node2D, b: Node2D) -> bool:
		return get_nearby_enemy_count(a.global_position) > get_nearby_enemy_count(b.global_position)
	)
	return candidates.front()


func get_nearby_enemy_count(center: Vector2) -> int:
	var count := 0
	var radius_squared := get_radius() * get_radius()
	for enemy in RuntimeQuery.get_active_enemies(self):
		if is_instance_valid(enemy) and center.distance_squared_to(enemy.global_position) <= radius_squared:
			count += 1
	return count


func get_enemies_in_radius(center: Vector2, radius: float) -> Array[Area2D]:
	var enemies: Array[Area2D] = []
	var radius_squared := radius * radius
	for enemy in RuntimeQuery.get_active_enemies(self):
		if not is_instance_valid(enemy):
			continue
		if enemy.has_method("is_damageable") and not enemy.is_damageable():
			continue
		if center.distance_squared_to(enemy.global_position) > radius_squared:
			continue
		enemies.append(enemy)
	return enemies


func get_damage() -> float:
	if player == null:
		return 0.0
	return player.attack_damage * DAMAGE_MULTIPLIER * pow(1.18, float(artillery_level - 1))


func _draw() -> void:
	if not has_telegraph:
		return
	
	var progress: float = clamp(1.0 - telegraph_timer / TELEGRAPH_TIME, 0.0, 1.0)
	var local_position := to_local(telegraph_position)
	var radius: float = get_radius()
	draw_circle(local_position, radius, Color(1.0, 0.18, 0.04, 0.13))
	draw_arc(local_position, radius * lerp(1.25, 0.72, progress), 0.0, TAU, 96, Color(1.0, 0.72, 0.08, 0.78), 4.0, true)
	draw_line(local_position + Vector2(-radius, 0.0), local_position + Vector2(radius, 0.0), Color(1.0, 0.4, 0.05, 0.58), 2.0)
	draw_line(local_position + Vector2(0.0, -radius), local_position + Vector2(0.0, radius), Color(1.0, 0.4, 0.05, 0.58), 2.0)
