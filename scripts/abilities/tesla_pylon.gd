extends Node2D

const RuntimeQuery = preload("res://scripts/core/runtime_query.gd")

const BASE_INTERVAL: float = 5.8
const INTERVAL_STEP: float = 0.28
const MIN_INTERVAL: float = 2.1
const TARGET_RANGE: float = 560.0
const BASE_RADIUS: float = 92.0
const RADIUS_PER_LEVEL: float = 8.0
const PYLON_DURATION: float = 2.4
const DAMAGE_INTERVAL: float = 0.34
const DAMAGE_MULTIPLIER: float = 0.36
const SLOW_DURATION: float = 0.3
const SLOW_MULTIPLIER: float = 0.68

var player: CharacterBody2D
var pylon_level: int = 1
var cast_timer: float = 0.0
var active_timer: float = 0.0
var damage_timer: float = 0.0
var pylon_position: Vector2 = Vector2.ZERO


func _process(delta: float) -> void:
	if player == null or player.is_dead:
		queue_free()
		return
	
	global_position = player.global_position
	cast_timer += delta
	if cast_timer >= get_interval() and active_timer <= 0.0:
		cast_timer = 0.0
		deploy_pylon()
	
	if active_timer > 0.0:
		active_timer = max(active_timer - delta, 0.0)
		damage_timer += delta
		if damage_timer >= DAMAGE_INTERVAL:
			damage_timer = 0.0
			zap_enemies()
		queue_redraw()


func configure(new_player: CharacterBody2D, new_level: int) -> void:
	player = new_player
	pylon_level = max(new_level, 1)
	cast_timer = randf_range(0.0, get_interval() * 0.45)


func update_level(new_level: int) -> void:
	pylon_level = max(new_level, 1)


func get_interval() -> float:
	return max(BASE_INTERVAL - float(pylon_level - 1) * INTERVAL_STEP, MIN_INTERVAL)


func get_radius() -> float:
	return BASE_RADIUS + float(pylon_level - 1) * RADIUS_PER_LEVEL


func deploy_pylon() -> void:
	var target := get_densest_enemy()
	if target == null:
		return
	pylon_position = target.global_position
	active_timer = PYLON_DURATION + float(pylon_level - 1) * 0.08
	damage_timer = DAMAGE_INTERVAL
	queue_redraw()


func get_densest_enemy() -> Node2D:
	var best_enemy: Node2D = null
	var best_score := -1
	var range_squared := TARGET_RANGE * TARGET_RANGE
	for enemy in RuntimeQuery.get_active_enemies(self):
		if not is_instance_valid(enemy) or not enemy is Node2D:
			continue
		if enemy.has_method("is_damageable") and not enemy.is_damageable():
			continue
		if player.global_position.distance_squared_to(enemy.global_position) > range_squared:
			continue
		var score := get_nearby_enemy_count(enemy.global_position)
		if score > best_score:
			best_score = score
			best_enemy = enemy
	return best_enemy


func get_nearby_enemy_count(center: Vector2) -> int:
	var radius_squared := get_radius() * get_radius()
	var count := 0
	for enemy in RuntimeQuery.get_active_enemies(self):
		if is_instance_valid(enemy) and center.distance_squared_to(enemy.global_position) <= radius_squared:
			count += 1
	return count


func zap_enemies() -> void:
	var radius_squared := get_radius() * get_radius()
	for enemy in RuntimeQuery.get_active_enemies(self):
		if not is_instance_valid(enemy):
			continue
		if enemy.has_method("is_damageable") and not enemy.is_damageable():
			continue
		if pylon_position.distance_squared_to(enemy.global_position) > radius_squared:
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
	return player.attack_damage * DAMAGE_MULTIPLIER * pow(1.09, float(pylon_level - 1)) * multiplier


func record_player_damage(amount: int) -> void:
	if amount <= 0:
		return
	var main := get_tree().current_scene
	if main and main.has_method("record_player_damage"):
		main.record_player_damage(amount)


func _draw() -> void:
	if active_timer <= 0.0:
		return
	var alpha: float = active_timer / (PYLON_DURATION + float(pylon_level - 1) * 0.08)
	var local_pylon := to_local(pylon_position)
	draw_circle(local_pylon, 7.0, Color(0.48, 0.9, 1.0, 0.9 * alpha))
	draw_arc(local_pylon, get_radius(), 0.0, TAU, 72, Color(0.42, 0.9, 1.0, 0.42 * alpha), 3.0, true)
