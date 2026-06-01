extends Node2D

const BASE_INTERVAL: float = 3.9
const INTERVAL_STEP: float = 0.2
const MIN_INTERVAL: float = 1.25
const BASE_RANGE: float = 430.0
const RANGE_PER_LEVEL: float = 16.0
const BASE_BOUNCES: int = 4
const DAMAGE_MULTIPLIER: float = 0.62
const BOUNCE_DAMAGE_FALLOFF: float = 0.84
const VISUAL_LIFETIME: float = 0.18

var player: CharacterBody2D
var ricochet_level: int = 1
var shot_timer: float = 0.0
var visual_timer: float = 0.0
var visual_points: Array[Vector2] = []


func _process(delta: float) -> void:
	if player == null or player.is_dead:
		queue_free()
		return
	
	global_position = player.global_position
	shot_timer += delta
	if shot_timer >= get_interval():
		shot_timer = 0.0
		fire_ricochet()
	
	visual_timer = max(visual_timer - delta, 0.0)
	if visual_timer > 0.0:
		queue_redraw()


func configure(new_player: CharacterBody2D, new_level: int) -> void:
	player = new_player
	ricochet_level = max(new_level, 1)
	shot_timer = randf_range(0.0, get_interval() * 0.5)


func update_level(new_level: int) -> void:
	ricochet_level = max(new_level, 1)


func get_interval() -> float:
	return max(BASE_INTERVAL - float(ricochet_level - 1) * INTERVAL_STEP, MIN_INTERVAL)


func get_range() -> float:
	return BASE_RANGE + float(ricochet_level - 1) * RANGE_PER_LEVEL


func get_bounce_count() -> int:
	return BASE_BOUNCES + int(floor(float(ricochet_level - 1) / 2.0))


func fire_ricochet() -> void:
	var struck := {}
	var current_position := global_position
	var damage := get_damage()
	visual_points = [global_position]
	
	for i in range(get_bounce_count()):
		var target := get_nearest_unstruck_enemy(current_position, struck)
		if target == null:
			break
		struck[target.get_instance_id()] = true
		visual_points.append(target.global_position)
		if target.has_method("hit"):
			var actual_damage: int = target.hit(damage)
			record_player_damage(actual_damage)
		current_position = target.global_position
		damage *= BOUNCE_DAMAGE_FALLOFF
	
	if visual_points.size() > 1:
		visual_timer = VISUAL_LIFETIME
		queue_redraw()


func get_nearest_unstruck_enemy(from_position: Vector2, struck: Dictionary) -> Node2D:
	var nearest: Node2D = null
	var nearest_distance := get_range() * get_range()
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		if not is_instance_valid(enemy):
			continue
		if struck.has(enemy.get_instance_id()):
			continue
		if enemy.has_method("is_damageable") and not enemy.is_damageable():
			continue
		var distance := from_position.distance_squared_to(enemy.global_position)
		if distance < nearest_distance:
			nearest = enemy
			nearest_distance = distance
	return nearest


func get_damage() -> float:
	if player == null:
		return 0.0
	var multiplier := 1.0
	if player.has_method("get_projectile_damage_multiplier"):
		multiplier = player.get_projectile_damage_multiplier()
	return player.attack_damage * DAMAGE_MULTIPLIER * pow(1.1, float(ricochet_level - 1)) * multiplier


func record_player_damage(amount: int) -> void:
	if amount <= 0:
		return
	var main := get_tree().current_scene
	if main and main.has_method("record_player_damage"):
		main.record_player_damage(amount)


func _draw() -> void:
	if visual_timer <= 0.0 or visual_points.size() < 2:
		return
	var alpha := visual_timer / VISUAL_LIFETIME
	for i in range(visual_points.size() - 1):
		draw_line(to_local(visual_points[i]), to_local(visual_points[i + 1]), Color(1.0, 0.92, 0.28, alpha), 3.0, true)
