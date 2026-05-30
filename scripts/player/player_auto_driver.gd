extends Node

const DIRECTION_CHANGE_INTERVAL: float = 1.0
const AVOIDANCE_UPDATE_INTERVAL: float = 0.2
const AVOIDANCE_PREDICTION_TIME: float = 0.85
const AVOIDANCE_SCAN_RADIUS: float = 300.0
const SAFE_ENEMY_DISTANCE: float = 150.0
const LOW_HEALTH_SAFE_ENEMY_DISTANCE: float = 220.0
const CRITICAL_HEALTH_SAFE_ENEMY_DISTANCE: float = 300.0
const LOW_HEALTH_RATIO: float = 0.4
const CRITICAL_HEALTH_RATIO: float = 0.2
const RANDOM_DIRECTION_WEIGHT: float = 30.0
const RANDOM_DIRECTION_MIN_INTERVAL: float = 1.4
const RANDOM_DIRECTION_MAX_INTERVAL: float = 2.8
const EXP_SEEK_DIRECTION_WEIGHT: float = 120.0
const EXP_SEEK_SCAN_RADIUS: float = 300.0
const EXP_SEEK_UPDATE_INTERVAL: float = 0.25
const EXP_PICKUP_COMMIT_DISTANCE: float = 42.0
const PICKUP_BORDER_COMMIT_DISTANCE: float = 70.0
const WRENCH_SEEK_DIRECTION_WEIGHT: float = 160.0
const WRENCH_SEEK_SCAN_RADIUS: float = 700.0
const SUPPLY_SEEK_DIRECTION_WEIGHT: float = 190.0
const SUPPLY_SEEK_SCAN_RADIUS: float = 800.0
const POWERUP_SEEK_DIRECTION_WEIGHT: float = 220.0
const POWERUP_SEEK_SCAN_RADIUS: float = 900.0
const OUT_OF_ARENA_PENALTY: float = 100000.0
const UNSAFE_DISTANCE_PENALTY: float = 10.0
const BOSS_CHARGE_DANGER_BUFFER: float = 36.0
const BOSS_CHARGE_DANGER_PENALTY: float = 80.0
const TARGET_ALIGNMENT_WEIGHT: float = 25.0
const CENTER_PULL_WEIGHT: float = 55.0
const CENTER_TARGET_WEIGHT: float = 65.0
const CENTER_IDLE_RADIUS: float = 120.0
const CENTER_DEADBAND_RADIUS: float = 190.0
const EDGE_BUFFER_DISTANCE: float = 190.0
const EDGE_PENALTY_WEIGHT: float = 12.0
const WALL_RECOVERY_DURATION: float = 1.2
const REACHABLE_TARGET_INSET: float = 20.0

var is_active: bool = false
var enemy_avoidance_active: bool = false
var exp_seek_active: bool = false
var wrench_seek_active: bool = false
var supply_seek_active: bool = false
var powerup_seek_active: bool = false
var upgrade_pick_active: bool = false
var movement_direction: Vector2 = Vector2.ZERO
var avoidance_direction: Vector2 = Vector2.ZERO
var direction_timer: float = 0.0
var avoidance_timer: float = 0.0
var exp_seek_timer: float = 0.0
var exp_seek_target: Node2D
var random_direction_interval: float = 1.0
var last_behavior_base_label: String = "off"
var preferred_direction_weight: float = RANDOM_DIRECTION_WEIGHT
var has_preferred_target: bool = false
var preferred_target_position: Vector2 = Vector2.ZERO
var current_behavior_label: String = "off"
var exp_seek_status: String = "exp idle"
var wall_recovery_timer: float = 0.0


func activate() -> void:
	is_active = true
	direction_timer = DIRECTION_CHANGE_INTERVAL
	avoidance_timer = AVOIDANCE_UPDATE_INTERVAL
	exp_seek_timer = EXP_SEEK_UPDATE_INTERVAL
	pick_random_direction()


func deactivate() -> void:
	is_active = false
	movement_direction = Vector2.ZERO
	avoidance_direction = Vector2.ZERO
	direction_timer = 0.0
	avoidance_timer = 0.0
	exp_seek_timer = 0.0
	exp_seek_target = null
	current_behavior_label = "off"


func set_enemy_avoidance_active(active: bool) -> void:
	enemy_avoidance_active = active
	avoidance_timer = AVOIDANCE_UPDATE_INTERVAL
	avoidance_direction = movement_direction


func set_exp_seek_active(active: bool) -> void:
	exp_seek_active = active
	avoidance_timer = AVOIDANCE_UPDATE_INTERVAL
	exp_seek_timer = EXP_SEEK_UPDATE_INTERVAL
	exp_seek_target = null


func set_wrench_seek_active(active: bool) -> void:
	wrench_seek_active = active
	avoidance_timer = AVOIDANCE_UPDATE_INTERVAL


func set_supply_seek_active(active: bool) -> void:
	supply_seek_active = active
	avoidance_timer = AVOIDANCE_UPDATE_INTERVAL


func set_powerup_seek_active(active: bool) -> void:
	powerup_seek_active = active
	avoidance_timer = AVOIDANCE_UPDATE_INTERVAL


func get_movement_vector(delta: float) -> Vector2:
	if not is_active:
		current_behavior_label = "off"
		return Vector2.ZERO
	
	wall_recovery_timer = max(wall_recovery_timer - delta, 0.0)
	direction_timer += delta
	if direction_timer >= random_direction_interval:
		direction_timer -= random_direction_interval
		pick_random_direction()
	
	update_exp_seek_target(delta)
	var preferred_direction: Vector2 = get_preferred_direction()
	if enemy_avoidance_active:
		avoidance_timer += delta
		if avoidance_timer >= AVOIDANCE_UPDATE_INTERVAL:
			avoidance_timer -= AVOIDANCE_UPDATE_INTERVAL
			avoidance_direction = get_enemy_avoidance_direction(preferred_direction)
		current_behavior_label = "%s + dodge" % current_behavior_label
		return avoidance_direction
	
	return preferred_direction


func pick_random_direction() -> void:
	var horizontal := randi_range(-1, 1)
	var vertical := randi_range(-1, 1)
	
	while horizontal == 0 and vertical == 0:
		horizontal = randi_range(-1, 1)
		vertical = randi_range(-1, 1)
	
	movement_direction = Vector2(horizontal, vertical).normalized()
	random_direction_interval = randf_range(RANDOM_DIRECTION_MIN_INTERVAL, RANDOM_DIRECTION_MAX_INTERVAL)


func get_preferred_direction() -> Vector2:
	var player := get_parent() as CharacterBody2D
	if player == null:
		return movement_direction
	
	preferred_direction_weight = RANDOM_DIRECTION_WEIGHT
	has_preferred_target = false
	if powerup_seek_active:
		var powerup: Node2D = get_nearest_node_in_groups(["DynamitePickup", "MagnetPickup"], POWERUP_SEEK_SCAN_RADIUS)
		if powerup != null:
			current_behavior_label = "powerup"
			return use_preferred_target(player, powerup.global_position, POWERUP_SEEK_DIRECTION_WEIGHT)
	
	if supply_seek_active:
		var supply_box: Node2D = get_nearest_node_in_groups(["SupplyBoxPickup"], SUPPLY_SEEK_SCAN_RADIUS)
		if supply_box != null:
			current_behavior_label = "supply box"
			return use_preferred_target(player, supply_box.global_position, SUPPLY_SEEK_DIRECTION_WEIGHT)
	
	if wrench_seek_active:
		var wrench: Node2D = get_nearest_wrench()
		if wrench != null:
			current_behavior_label = "wrench"
			return use_preferred_target(player, wrench.global_position, WRENCH_SEEK_DIRECTION_WEIGHT)
	
	if exp_seek_active:
		if is_instance_valid(exp_seek_target) and exp_seek_target.is_inside_tree():
			current_behavior_label = exp_seek_status
			var exp_direction := use_preferred_target(player, exp_seek_target.global_position, EXP_SEEK_DIRECTION_WEIGHT)
			if player.global_position.distance_to(exp_seek_target.global_position) <= EXP_PICKUP_COMMIT_DISTANCE:
				current_behavior_label = "exp commit"
				return exp_direction
			
			return exp_direction
		current_behavior_label = exp_seek_status
	
	var center_target: Vector2 = get_center_target_position(player)
	if center_target != Vector2.INF:
		current_behavior_label = "center"
		return use_preferred_target(player, center_target, CENTER_TARGET_WEIGHT)
	
	current_behavior_label = "random"
	return movement_direction


func use_preferred_target(player: CharacterBody2D, target_position: Vector2, target_weight: float) -> Vector2:
	has_preferred_target = true
	preferred_target_position = get_reachable_target_position(target_position)
	preferred_direction_weight = target_weight
	return player.global_position.direction_to(preferred_target_position)


func get_reachable_target_position(target_position: Vector2) -> Vector2:
	var main := get_tree().current_scene
	if main == null or not main.has_method("get_arena_rect"):
		return target_position
	
	var arena_rect: Rect2 = main.get_arena_rect()
	return Vector2(
		clamp(target_position.x, arena_rect.position.x + REACHABLE_TARGET_INSET, arena_rect.end.x - REACHABLE_TARGET_INSET),
		clamp(target_position.y, arena_rect.position.y + REACHABLE_TARGET_INSET, arena_rect.end.y - REACHABLE_TARGET_INSET)
	)


func get_nearest_wrench() -> Node2D:
	var player := get_parent() as CharacterBody2D
	if player == null or player.health >= player.max_health:
		return null
	
	return get_nearest_node_in_groups(["WrenchPickup"], WRENCH_SEEK_SCAN_RADIUS)


func get_nearest_node_in_groups(group_names: Array[String], scan_radius: float) -> Node2D:
	var player := get_parent() as CharacterBody2D
	if player == null:
		return null
	
	var nearest_pickup: Node2D = null
	var nearest_distance: float = INF
	var scan_radius_squared: float = scan_radius * scan_radius
	for group_name in group_names:
		for pickup in get_tree().get_nodes_in_group(group_name):
			if not is_instance_valid(pickup) or not pickup is Node2D:
				continue
			if "is_active" in pickup and not pickup.is_active:
				continue
			
			var distance: float = player.global_position.distance_squared_to(pickup.global_position)
			if distance < nearest_distance and distance <= scan_radius_squared:
				nearest_pickup = pickup
				nearest_distance = distance
	
	return nearest_pickup


func update_exp_seek_target(delta: float) -> void:
	if not exp_seek_active:
		exp_seek_target = null
		return
	
	if exp_seek_target != null and (not is_instance_valid(exp_seek_target) or not exp_seek_target.is_inside_tree()):
		exp_seek_target = null
		exp_seek_timer = EXP_SEEK_UPDATE_INTERVAL
	
	exp_seek_timer += delta
	if exp_seek_timer < EXP_SEEK_UPDATE_INTERVAL:
		return
	
	exp_seek_timer -= EXP_SEEK_UPDATE_INTERVAL
	exp_seek_target = get_valid_exp_seek_target()


func get_valid_exp_seek_target() -> Node2D:
	var player := get_parent() as CharacterBody2D
	if player == null:
		exp_seek_status = "exp no player"
		return null
	
	var nearby_crystals: Array[Node2D] = get_awareness_nodes_in_group("ExpOrb")
	var nearby_enemies: Array[Node2D] = get_awareness_nodes_in_group("Enemy")
	if nearby_crystals.is_empty():
		var nearest_global_crystal: Node2D = get_nearest_node_in_groups(["ExpOrb"], INF)
		if nearest_global_crystal == null:
			exp_seek_status = "exp none"
			return null
		
		exp_seek_status = "exp search"
		return nearest_global_crystal
	
	var nearest_crystal: Node2D = get_nearest_node_from_list(nearby_crystals, player.global_position)
	if nearest_crystal == null:
		exp_seek_status = "exp none <300"
		return null
	if nearby_enemies.is_empty():
		exp_seek_status = "exp clear"
		return nearest_crystal
	
	var crystal_distance: float = player.global_position.distance_to(nearest_crystal.global_position)
	var nearest_enemy: Node2D = get_nearest_node_from_list(nearby_enemies, player.global_position)
	var nearest_enemy_distance: float = INF if nearest_enemy == null else player.global_position.distance_to(nearest_enemy.global_position)
	if crystal_distance < nearest_enemy_distance:
		exp_seek_status = "exp"
		return nearest_crystal
	
	exp_seek_status = "exp blocked"
	return null


func get_nearest_enemy_distance(from_position: Vector2) -> float:
	var nearest_distance: float = INF
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		if not is_instance_valid(enemy) or not enemy is Node2D:
			continue
		if enemy.has_method("is_damageable") and not enemy.is_damageable():
			continue
		
		nearest_distance = min(nearest_distance, from_position.distance_to(enemy.global_position))
	
	return nearest_distance


func get_awareness_nodes_in_group(group_name: String) -> Array[Node2D]:
	var nodes: Array[Node2D] = []
	var player := get_parent() as Node
	if player == null:
		return nodes
	
	var awareness_area := player.get_node_or_null("ExpAwarenessArea") as Area2D
	if awareness_area == null:
		return nodes
	
	for area in awareness_area.get_overlapping_areas():
		if not is_instance_valid(area) or not area is Node2D:
			continue
		if not area.is_in_group(group_name):
			continue
		if "is_active" in area and not area.is_active:
			continue
		if area.has_method("is_damageable") and not area.is_damageable():
			continue
		
		nodes.append(area)
	
	if nodes.is_empty():
		nodes = get_nodes_in_group_within_distance(group_name, awareness_area.global_position, EXP_SEEK_SCAN_RADIUS)
	
	return nodes


func get_nodes_in_group_within_distance(group_name: String, center: Vector2, radius: float) -> Array[Node2D]:
	var nodes: Array[Node2D] = []
	var radius_squared: float = radius * radius
	for node in get_tree().get_nodes_in_group(group_name):
		if not is_instance_valid(node) or not node is Node2D:
			continue
		if "is_active" in node and not node.is_active:
			continue
		if node.has_method("is_damageable") and not node.is_damageable():
			continue
		if center.distance_squared_to(node.global_position) > radius_squared:
			continue
		
		nodes.append(node)
	
	return nodes


func get_nearest_node_from_list(nodes: Array[Node2D], from_position: Vector2) -> Node2D:
	var nearest_node: Node2D = null
	var nearest_distance: float = INF
	for node in nodes:
		if not is_instance_valid(node):
			continue
		
		var distance: float = from_position.distance_squared_to(node.global_position)
		if distance < nearest_distance:
			nearest_node = node
			nearest_distance = distance
	
	return nearest_node


func get_enemy_avoidance_direction(preferred_direction: Vector2) -> Vector2:
	var behavior_label_before_dodge: String = current_behavior_label
	var player := get_parent() as CharacterBody2D
	if player == null:
		return preferred_direction
	
	var enemies: Array = get_tree().get_nodes_in_group("Enemy")
	var best_direction: Vector2 = preferred_direction
	var best_score: float = -INF
	
	for candidate_direction in get_candidate_directions(preferred_direction):
		var score: float = score_candidate_direction(player, candidate_direction, preferred_direction, enemies)
		if score > best_score:
			best_score = score
			best_direction = candidate_direction
	
	current_behavior_label = behavior_label_before_dodge
	return best_direction.normalized()


func trigger_wall_recovery() -> void:
	wall_recovery_timer = WALL_RECOVERY_DURATION


func get_center_target_position(player: CharacterBody2D) -> Vector2:
	if wall_recovery_timer <= 0.0:
		return Vector2.INF
	
	var main := get_tree().current_scene
	if main == null or not main.has_method("get_arena_rect"):
		return Vector2.INF
	
	var center: Vector2 = main.get_arena_rect().get_center()
	if current_behavior_label == "center" and player.global_position.distance_to(center) > CENTER_IDLE_RADIUS:
		return center
	if player.global_position.distance_to(center) <= CENTER_DEADBAND_RADIUS:
		return Vector2.INF
	
	return center


func get_candidate_directions(preferred_direction: Vector2) -> Array[Vector2]:
	var directions: Array[Vector2] = [
		Vector2.RIGHT,
		Vector2(1.0, 1.0).normalized(),
		Vector2.DOWN,
		Vector2(-1.0, 1.0).normalized(),
		Vector2.LEFT,
		Vector2(-1.0, -1.0).normalized(),
		Vector2.UP,
		Vector2(1.0, -1.0).normalized(),
	]
	
	if preferred_direction != Vector2.ZERO:
		directions.append(preferred_direction.normalized())
		directions.append(-preferred_direction.normalized())
	
	return directions


func score_candidate_direction(player: CharacterBody2D, candidate_direction: Vector2, preferred_direction: Vector2, enemies: Array) -> float:
	var predicted_position: Vector2 = player.global_position + candidate_direction * player.speed * AVOIDANCE_PREDICTION_TIME
	var score: float = candidate_direction.dot(preferred_direction.normalized()) * TARGET_ALIGNMENT_WEIGHT
	var is_exp_commit: bool = has_preferred_target and current_behavior_label == "exp commit"
	var is_pickup_commit: bool = has_preferred_target and player.global_position.distance_to(preferred_target_position) <= PICKUP_BORDER_COMMIT_DISTANCE
	if is_pickup_commit and candidate_direction.dot(player.global_position.direction_to(preferred_target_position)) > 0.5:
		predicted_position = preferred_target_position
	var health_ratio: float = player.get_health_ratio() if player.has_method("get_health_ratio") else 1.0
	var safe_enemy_distance: float = get_health_adjusted_safe_enemy_distance(health_ratio)
	var unsafe_penalty_weight: float = get_health_adjusted_unsafe_penalty_weight(health_ratio)
	var target_weight_multiplier: float = get_health_adjusted_target_weight_multiplier(health_ratio)
	if has_preferred_target:
		var current_target_distance: float = player.global_position.distance_to(preferred_target_position)
		var predicted_target_distance: float = predicted_position.distance_to(preferred_target_position)
		score += (current_target_distance - predicted_target_distance) * preferred_direction_weight * target_weight_multiplier
	
	var main := get_tree().current_scene
	if main and main.has_method("is_position_in_arena") and not main.is_position_in_arena(predicted_position):
		score -= OUT_OF_ARENA_PENALTY
	if wall_recovery_timer > 0.0 and not has_preferred_target and main and main.has_method("get_arena_rect"):
		var arena_rect: Rect2 = main.get_arena_rect()
		score += get_centering_score(player.global_position, predicted_position, arena_rect)
	
	for enemy in enemies:
		if not is_instance_valid(enemy) or not enemy is Node2D:
			continue
		
		var enemy_position: Vector2 = enemy.global_position
		var current_distance: float = player.global_position.distance_to(enemy_position)
		if current_distance > AVOIDANCE_SCAN_RADIUS:
			continue
		
		var future_distance: float = predicted_position.distance_to(enemy_position)
		if health_ratio <= CRITICAL_HEALTH_RATIO:
			score += future_distance * 30.0
		if future_distance < safe_enemy_distance:
			var commit_multiplier: float = 0.35 if is_pickup_commit and health_ratio > CRITICAL_HEALTH_RATIO else 1.0
			score -= pow(safe_enemy_distance - future_distance, 2.0) * unsafe_penalty_weight * commit_multiplier
	
	score -= get_boss_charge_danger_penalty(predicted_position)
	
	return score


func get_boss_charge_danger_penalty(predicted_position: Vector2) -> float:
	var penalty: float = 0.0
	for danger_line in get_tree().get_nodes_in_group("BossChargeDanger"):
		if not is_instance_valid(danger_line) or not danger_line is Line2D:
			continue
		if not danger_line.visible or danger_line.get_point_count() < 2:
			continue
		
		var start_position: Vector2 = danger_line.to_global(danger_line.get_point_position(0))
		var end_position: Vector2 = danger_line.to_global(danger_line.get_point_position(1))
		var closest_position: Vector2 = get_segment_closest_point(start_position, end_position, predicted_position)
		var danger_width: float = float(danger_line.get_meta("danger_width", danger_line.width))
		var danger_radius: float = danger_width * 0.5 + BOSS_CHARGE_DANGER_BUFFER
		var distance: float = predicted_position.distance_to(closest_position)
		if distance < danger_radius:
			penalty += pow(danger_radius - distance, 2.0) * BOSS_CHARGE_DANGER_PENALTY
	
	return penalty


func get_segment_closest_point(start_position: Vector2, end_position: Vector2, point: Vector2) -> Vector2:
	var segment: Vector2 = end_position - start_position
	var segment_length_squared: float = segment.length_squared()
	if is_zero_approx(segment_length_squared):
		return start_position
	
	var distance_ratio: float = clamp((point - start_position).dot(segment) / segment_length_squared, 0.0, 1.0)
	return start_position + segment * distance_ratio


func get_health_adjusted_safe_enemy_distance(health_ratio: float) -> float:
	if health_ratio <= CRITICAL_HEALTH_RATIO:
		return CRITICAL_HEALTH_SAFE_ENEMY_DISTANCE
	if health_ratio <= LOW_HEALTH_RATIO:
		return LOW_HEALTH_SAFE_ENEMY_DISTANCE
	return SAFE_ENEMY_DISTANCE


func get_health_adjusted_unsafe_penalty_weight(health_ratio: float) -> float:
	if health_ratio <= CRITICAL_HEALTH_RATIO:
		return UNSAFE_DISTANCE_PENALTY * 6.0
	if health_ratio <= LOW_HEALTH_RATIO:
		return UNSAFE_DISTANCE_PENALTY * 2.0
	return UNSAFE_DISTANCE_PENALTY


func get_health_adjusted_target_weight_multiplier(health_ratio: float) -> float:
	if health_ratio <= CRITICAL_HEALTH_RATIO:
		return 0.15
	if health_ratio <= LOW_HEALTH_RATIO:
		return 0.65
	return 1.0


func get_centering_score(current_position: Vector2, predicted_position: Vector2, arena_rect: Rect2) -> float:
	var center: Vector2 = arena_rect.get_center()
	var score: float = (current_position.distance_to(center) - predicted_position.distance_to(center)) * CENTER_PULL_WEIGHT
	var edge_distance: float = get_minimum_edge_distance(predicted_position, arena_rect)
	if edge_distance < EDGE_BUFFER_DISTANCE:
		score -= pow(EDGE_BUFFER_DISTANCE - edge_distance, 2.0) * EDGE_PENALTY_WEIGHT
	return score


func get_minimum_edge_distance(position: Vector2, rect: Rect2) -> float:
	return min(
		position.x - rect.position.x,
		rect.end.x - position.x,
		position.y - rect.position.y,
		rect.end.y - position.y
	)
