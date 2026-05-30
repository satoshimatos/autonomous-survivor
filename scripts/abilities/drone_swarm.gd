extends Node2D

const ORBIT_RADIUS: float = 74.0
const ORBIT_RADIUS_STEP: float = 11.0
const ORBIT_SPEED: float = TAU * 0.42
const FIRE_INTERVAL: float = 0.65
const FIRE_INTERVAL_STEP: float = 0.035
const MIN_FIRE_INTERVAL: float = 0.22
const TARGET_RANGE: float = 430.0
const DAMAGE_MULTIPLIER: float = 0.38

var player: CharacterBody2D
var drone_level: int = 1
var orbit_angle: float = 0.0
var fire_timer: float = 0.0


func _process(delta: float) -> void:
	if player == null or player.is_dead:
		queue_free()
		return
	
	global_position = player.global_position
	orbit_angle += ORBIT_SPEED * delta
	fire_timer += delta
	if fire_timer >= get_fire_interval():
		fire_timer = 0.0
		fire_drones()
	queue_redraw()


func configure(new_player: CharacterBody2D, new_level: int) -> void:
	player = new_player
	drone_level = max(new_level, 1)
	fire_timer = randf_range(0.0, get_fire_interval())


func update_level(new_level: int) -> void:
	drone_level = max(new_level, 1)


func get_fire_interval() -> float:
	return max(FIRE_INTERVAL - float(drone_level - 1) * FIRE_INTERVAL_STEP, MIN_FIRE_INTERVAL)


func get_drone_count() -> int:
	return mini(2 + drone_level, 10)


func fire_drones() -> void:
	var drones := get_drone_count()
	for i in range(drones):
		var drone_position := get_drone_position(i, drones)
		var target := get_nearest_enemy(drone_position)
		if target == null:
			continue
		
		if target.has_method("hit"):
			var actual_damage: int = target.hit(get_damage())
			var main := get_tree().current_scene
			if actual_damage > 0 and main and main.has_method("record_player_damage"):
				main.record_player_damage(actual_damage)
			spawn_drone_burst(drone_position, target.global_position)


func get_damage() -> float:
	if player == null:
		return 0.0
	return player.attack_damage * DAMAGE_MULTIPLIER * pow(1.08, float(drone_level - 1))


func get_nearest_enemy(from_position: Vector2) -> Node2D:
	var nearest: Node2D = null
	var nearest_distance := TARGET_RANGE * TARGET_RANGE
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		if not is_instance_valid(enemy):
			continue
		if enemy.has_method("is_damageable") and not enemy.is_damageable():
			continue
		
		var distance := from_position.distance_squared_to(enemy.global_position)
		if distance < nearest_distance:
			nearest = enemy
			nearest_distance = distance
	
	return nearest


func spawn_drone_burst(from_position: Vector2, to_position: Vector2) -> void:
	var main := get_tree().current_scene
	if main == null or not main.has_method("spawn_particle_burst"):
		return
	
	main.spawn_particle_burst(main, to_position, 5, Color(0.55, 1.0, 0.45, 1.0), 90.0, 0.1, Vector2(0.8, 1.2), true)
	main.spawn_particle_burst(main, from_position, 3, Color(0.55, 1.0, 0.45, 0.8), 45.0, 0.08, Vector2(0.6, 1.0), true)


func get_drone_position(index: int, drone_count: int) -> Vector2:
	var spacing := TAU * float(index) / float(max(drone_count, 1))
	var radius := ORBIT_RADIUS + float(index % 3) * ORBIT_RADIUS_STEP
	return global_position + Vector2.RIGHT.rotated(orbit_angle + spacing) * radius


func _draw() -> void:
	var drones := get_drone_count()
	for i in range(drones):
		var local_position := to_local(get_drone_position(i, drones))
		draw_circle(local_position, 5.5, Color(0.25, 1.0, 0.42, 0.9))
		draw_circle(local_position, 2.5, Color(0.85, 1.0, 0.8, 1.0))
