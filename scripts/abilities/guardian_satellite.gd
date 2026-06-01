extends Node2D

const BASE_RADIUS: float = 92.0
const RADIUS_STEP: float = 8.0
const ORBIT_SPEED: float = TAU * 0.55
const DAMAGE_INTERVAL: float = 0.28
const DAMAGE_MULTIPLIER: float = 0.24
const SATELLITE_RADIUS: float = 18.0

var player: CharacterBody2D
var satellite_level: int = 1
var orbit_angle: float = 0.0
var hit_cooldowns := {}


func _process(delta: float) -> void:
	if player == null or player.is_dead:
		queue_free()
		return
	
	global_position = player.global_position
	orbit_angle += ORBIT_SPEED * delta
	update_hit_cooldowns(delta)
	apply_contact_damage()
	queue_redraw()


func configure(new_player: CharacterBody2D, new_level: int) -> void:
	player = new_player
	satellite_level = max(new_level, 1)
	orbit_angle = randf() * TAU


func update_level(new_level: int) -> void:
	satellite_level = max(new_level, 1)


func get_satellite_count() -> int:
	return mini(1 + satellite_level, 8)


func get_orbit_radius() -> float:
	return BASE_RADIUS + float(satellite_level - 1) * RADIUS_STEP


func update_hit_cooldowns(delta: float) -> void:
	for enemy_id in hit_cooldowns.keys():
		hit_cooldowns[enemy_id] = max(float(hit_cooldowns[enemy_id]) - delta, 0.0)


func apply_contact_damage() -> void:
	var active_enemy_ids := {}
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		if not is_instance_valid(enemy):
			continue
		if enemy.has_method("is_damageable") and not enemy.is_damageable():
			continue
		
		for i in range(get_satellite_count()):
			var satellite_position := get_satellite_position(i)
			var radius := SATELLITE_RADIUS + EnemyGeometry.get_collision_radius(enemy)
			if satellite_position.distance_squared_to(enemy.global_position) > radius * radius:
				continue
			
			var enemy_id: int = enemy.get_instance_id()
			active_enemy_ids[enemy_id] = true
			if not hit_cooldowns.has(enemy_id):
				hit_cooldowns[enemy_id] = 0.0
			if float(hit_cooldowns[enemy_id]) > 0.0:
				continue
			
			if enemy.has_method("hit"):
				var actual_damage: int = enemy.hit(get_damage())
				record_player_damage(actual_damage)
			hit_cooldowns[enemy_id] = DAMAGE_INTERVAL
			break
	
	for enemy_id in hit_cooldowns.keys():
		if not active_enemy_ids.has(enemy_id):
			hit_cooldowns.erase(enemy_id)


func get_satellite_position(index: int) -> Vector2:
	var spacing := TAU * float(index) / float(max(get_satellite_count(), 1))
	return global_position + Vector2.RIGHT.rotated(orbit_angle + spacing) * get_orbit_radius()


func get_damage() -> float:
	if player == null:
		return 0.0
	var multiplier := 1.0
	if player.has_method("get_power_damage_multiplier"):
		multiplier = player.get_power_damage_multiplier()
	return player.attack_damage * DAMAGE_MULTIPLIER * pow(1.08, float(satellite_level - 1)) * multiplier


func record_player_damage(amount: int) -> void:
	if amount <= 0:
		return
	var main := get_tree().current_scene
	if main and main.has_method("record_player_damage"):
		main.record_player_damage(amount)


func _draw() -> void:
	for i in range(get_satellite_count()):
		var local_position := to_local(get_satellite_position(i))
		draw_circle(local_position, SATELLITE_RADIUS, Color(0.9, 0.6, 0.18, 0.18))
		draw_circle(local_position, 7.0, Color(1.0, 0.72, 0.2, 0.9))
		draw_circle(local_position, 3.0, Color(1.0, 0.95, 0.55, 1.0))
