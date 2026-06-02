extends Node2D

const RuntimeQuery = preload("res://scripts/core/runtime_query.gd")

const BASE_INTERVAL: float = 3.8
const INTERVAL_STEP: float = 0.2
const MIN_INTERVAL: float = 1.2
const TARGET_RANGE: float = 640.0
const BEAM_LENGTH: float = 720.0
const BEAM_WIDTH: float = 18.0
const DAMAGE_MULTIPLIER: float = 1.05
const VISUAL_LIFETIME: float = 0.16

var player: CharacterBody2D
var railgun_level: int = 1
var fire_timer: float = 0.0
var visual_timer: float = 0.0
var beam_start: Vector2 = Vector2.ZERO
var beam_end: Vector2 = Vector2.ZERO


func _process(delta: float) -> void:
	if player == null or player.is_dead:
		queue_free()
		return
	
	global_position = player.global_position
	fire_timer += delta
	if fire_timer >= get_interval():
		fire_timer = 0.0
		fire_beam()
	
	visual_timer = max(visual_timer - delta, 0.0)
	if visual_timer > 0.0:
		queue_redraw()


func configure(new_player: CharacterBody2D, new_level: int) -> void:
	player = new_player
	railgun_level = max(new_level, 1)
	fire_timer = randf_range(0.0, get_interval() * 0.5)


func update_level(new_level: int) -> void:
	railgun_level = max(new_level, 1)


func get_interval() -> float:
	return max(BASE_INTERVAL - float(railgun_level - 1) * INTERVAL_STEP, MIN_INTERVAL)


func get_pierce_count() -> int:
	return 4 + railgun_level


func fire_beam() -> void:
	var target := get_nearest_enemy()
	if target == null:
		return
	
	var direction: Vector2 = global_position.direction_to(target.global_position)
	beam_start = global_position
	beam_end = global_position + direction * BEAM_LENGTH
	var targets := get_enemies_on_beam(direction)
	for enemy in targets:
		if enemy.has_method("hit"):
			var actual_damage: int = enemy.hit(get_damage())
			record_player_damage(actual_damage)
	
	visual_timer = VISUAL_LIFETIME
	queue_redraw()


func get_nearest_enemy() -> Node2D:
	var nearest: Node2D = null
	var nearest_distance := TARGET_RANGE * TARGET_RANGE
	for enemy in RuntimeQuery.get_active_enemies(self):
		if not is_instance_valid(enemy):
			continue
		if enemy.has_method("is_damageable") and not enemy.is_damageable():
			continue
		var distance := global_position.distance_squared_to(enemy.global_position)
		if distance < nearest_distance:
			nearest = enemy
			nearest_distance = distance
	return nearest


func get_enemies_on_beam(direction: Vector2) -> Array[Node2D]:
	var hits: Array[Dictionary] = []
	for enemy in RuntimeQuery.get_active_enemies(self):
		if not is_instance_valid(enemy) or not enemy is Node2D:
			continue
		if enemy.has_method("is_damageable") and not enemy.is_damageable():
			continue
		var to_enemy: Vector2 = enemy.global_position - global_position
		var along: float = to_enemy.dot(direction)
		if along < 0.0 or along > BEAM_LENGTH:
			continue
		var perpendicular_distance: float = abs(to_enemy.cross(direction))
		if perpendicular_distance > BEAM_WIDTH:
			continue
		hits.append({"enemy": enemy, "along": along})
	
	hits.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.along) < float(b.along)
	)
	
	var enemies: Array[Node2D] = []
	for i in range(mini(get_pierce_count(), hits.size())):
		enemies.append(hits[i].enemy)
	return enemies


func get_damage() -> float:
	if player == null:
		return 0.0
	var multiplier := 1.0
	if player.has_method("get_power_damage_multiplier"):
		multiplier = player.get_power_damage_multiplier()
	return player.attack_damage * DAMAGE_MULTIPLIER * pow(1.12, float(railgun_level - 1)) * multiplier


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
	draw_line(to_local(beam_start), to_local(beam_end), Color(0.92, 0.98, 1.0, alpha), 6.0, true)
	draw_line(to_local(beam_start), to_local(beam_end), Color(0.25, 0.72, 1.0, alpha * 0.75), 2.0, true)
