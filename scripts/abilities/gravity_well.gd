extends Node2D

const BASE_INTERVAL: float = 6.2
const INTERVAL_STEP: float = 0.3
const MIN_INTERVAL: float = 2.4
const BASE_RADIUS: float = 96.0
const RADIUS_PER_LEVEL: float = 10.0
const TARGET_RANGE: float = 540.0
const WELL_DURATION: float = 1.8
const DAMAGE_INTERVAL: float = 0.36
const DAMAGE_MULTIPLIER: float = 0.25
const PULL_STRENGTH: float = 48.0
const SLOW_DURATION: float = 0.45
const SLOW_MULTIPLIER: float = 0.48

var player: CharacterBody2D
var well_level: int = 1
var cast_timer: float = 0.0
var active_timer: float = 0.0
var damage_timer: float = 0.0
var well_position: Vector2 = Vector2.ZERO


func _process(delta: float) -> void:
	if player == null or player.is_dead:
		queue_free()
		return
	
	global_position = player.global_position
	cast_timer += delta
	if cast_timer >= get_interval() and active_timer <= 0.0:
		cast_timer = 0.0
		open_well()
	
	if active_timer > 0.0:
		active_timer = max(active_timer - delta, 0.0)
		damage_timer += delta
		apply_pull(delta)
		if damage_timer >= DAMAGE_INTERVAL:
			damage_timer = 0.0
			damage_enemies()
		queue_redraw()


func configure(new_player: CharacterBody2D, new_level: int) -> void:
	player = new_player
	well_level = max(new_level, 1)
	cast_timer = randf_range(0.0, get_interval() * 0.45)


func update_level(new_level: int) -> void:
	well_level = max(new_level, 1)


func get_interval() -> float:
	return max(BASE_INTERVAL - float(well_level - 1) * INTERVAL_STEP, MIN_INTERVAL)


func get_radius() -> float:
	return BASE_RADIUS + float(well_level - 1) * RADIUS_PER_LEVEL


func open_well() -> void:
	var target := get_densest_enemy()
	if target == null:
		return
	well_position = target.global_position
	active_timer = WELL_DURATION + float(well_level - 1) * 0.08
	damage_timer = DAMAGE_INTERVAL
	queue_redraw()


func get_densest_enemy() -> Node2D:
	var best_enemy: Node2D = null
	var best_score := -1
	var range_squared := TARGET_RANGE * TARGET_RANGE
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		if not is_instance_valid(enemy):
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
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		if is_instance_valid(enemy) and center.distance_squared_to(enemy.global_position) <= radius_squared:
			count += 1
	return count


func apply_pull(delta: float) -> void:
	var radius_squared := get_radius() * get_radius()
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		if not is_instance_valid(enemy) or not enemy is Node2D:
			continue
		if enemy.has_method("is_damageable") and not enemy.is_damageable():
			continue
		if well_position.distance_squared_to(enemy.global_position) > radius_squared:
			continue
		var direction: Vector2 = enemy.global_position.direction_to(well_position)
		enemy.global_position += direction * PULL_STRENGTH * delta
		if enemy.has_method("apply_slow"):
			enemy.apply_slow(SLOW_DURATION, SLOW_MULTIPLIER)


func damage_enemies() -> void:
	var radius_squared := get_radius() * get_radius()
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		if not is_instance_valid(enemy):
			continue
		if enemy.has_method("is_damageable") and not enemy.is_damageable():
			continue
		if well_position.distance_squared_to(enemy.global_position) > radius_squared:
			continue
		if enemy.has_method("hit"):
			var actual_damage: int = enemy.hit(get_damage())
			record_player_damage(actual_damage)


func get_damage() -> float:
	if player == null:
		return 0.0
	var multiplier := 1.0
	if player.has_method("get_power_damage_multiplier"):
		multiplier = player.get_power_damage_multiplier()
	return player.attack_damage * DAMAGE_MULTIPLIER * pow(1.08, float(well_level - 1)) * multiplier


func record_player_damage(amount: int) -> void:
	if amount <= 0:
		return
	var main := get_tree().current_scene
	if main and main.has_method("record_player_damage"):
		main.record_player_damage(amount)


func _draw() -> void:
	if active_timer <= 0.0:
		return
	var alpha: float = active_timer / (WELL_DURATION + float(well_level - 1) * 0.08)
	var local_well := to_local(well_position)
	draw_circle(local_well, get_radius(), Color(0.48, 0.28, 1.0, 0.1 + alpha * 0.08))
	draw_arc(local_well, get_radius() * (0.72 + alpha * 0.2), 0.0, TAU, 84, Color(0.76, 0.58, 1.0, 0.42 * alpha), 4.0, true)
