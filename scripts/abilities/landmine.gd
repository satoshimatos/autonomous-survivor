extends Area2D

const TRIGGER_RADIUS: float = 17.5
const EXPLOSION_RADIUS: float = 70.0
const DETONATION_DELAY: float = 0.5

var player: CharacterBody2D
var damage_multiplier: float = 2.0
var detonation_timer: float = 0.0
var is_detonating: bool = false
var has_exploded: bool = false


func _ready() -> void:
	add_to_group("Landmine")
	call_deferred("check_overlapping_enemies")


func _process(delta: float) -> void:
	if not is_detonating or has_exploded:
		return
	
	detonation_timer -= delta
	if detonation_timer <= 0.0:
		explode()


func _on_area_entered(area: Area2D) -> void:
	if has_exploded:
		return
	
	if area.is_in_group("Enemy"):
		start_detonation()


func check_overlapping_enemies() -> void:
	if has_exploded:
		return
	
	for area in get_overlapping_areas():
		if area.is_in_group("Enemy"):
			start_detonation()
			return


func start_detonation() -> void:
	if is_detonating or has_exploded:
		return
	
	is_detonating = true
	detonation_timer = DETONATION_DELAY
	$PickupSprite.modulate = Color(1.0, 0.45, 0.18, 1.0)


func check_overlapping_landmines() -> void:
	if has_exploded:
		return
	
	var overlapping_landmines: Array[Node] = []
	for landmine in get_tree().get_nodes_in_group("Landmine"):
		if landmine == self:
			continue
		if not is_instance_valid(landmine):
			continue
		if not landmine.has_method("trigger_immediate_explosion"):
			continue
		if global_position.distance_to(landmine.global_position) <= TRIGGER_RADIUS * 2.0:
			overlapping_landmines.append(landmine)
	
	if overlapping_landmines.is_empty():
		return
	
	overlapping_landmines.append(self)
	for landmine in overlapping_landmines:
		if is_instance_valid(landmine):
			landmine.trigger_immediate_explosion()


func trigger_immediate_explosion() -> void:
	if has_exploded:
		return
	
	call_deferred("explode")


func explode() -> void:
	if has_exploded:
		return
	
	has_exploded = true
	remove_from_group("Landmine")
	var main := get_tree().current_scene
	if main and main.has_method("_spawn_splash_area"):
		var enemies := get_enemies_in_radius()
		var damage := get_explosion_damage()
		main.call_deferred("_spawn_splash_area", global_position, EXPLOSION_RADIUS, damage, enemies)
	
	queue_free()


func get_explosion_damage() -> float:
	if player == null:
		return 0.0
	
	return player.attack_damage * damage_multiplier


func get_enemies_in_radius() -> Array[Area2D]:
	var enemies: Array[Area2D] = []
	var seen_enemies := {}
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		if not is_instance_valid(enemy):
			continue
		if seen_enemies.has(enemy):
			continue
		if enemy.has_method("is_damageable") and not enemy.is_damageable():
			continue
		
		var overlap_radius: float = EXPLOSION_RADIUS + EnemyGeometry.get_collision_radius(enemy)
		if global_position.distance_to(enemy.global_position) <= overlap_radius:
			enemies.append(enemy)
			seen_enemies[enemy] = true
	
	return enemies
