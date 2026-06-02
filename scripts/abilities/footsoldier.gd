extends Node2D

const RuntimeQuery = preload("res://scripts/core/runtime_query.gd")

const SHOOT_RANGE: float = 400.0
const NEAR_PLAYER_DISTANCE: float = 50.0
const BURST_SHOT_COUNT: int = 3
const BURST_SHOT_INTERVAL: float = 0.06
const SHOOT_WINDUP: float = 0.3
const SHOOT_RECOVERY: float = 0.3
const FOLLOW_DELAY: float = 0.3
const FOLLOW_COLUMN_COUNT: int = 5
const FOLLOW_COLUMN_SPACING: float = 12.0
const FOLLOW_ROW_SPACING: float = 10.0
const FOLLOW_BACK_OFFSET: float = 24.0
const FOLLOW_SPEED: float = 165.0
const CATCH_UP_SPEED: float = 375.0
const CATCH_UP_DISTANCE: float = 110.0
const PROJECTILE = preload("uid://bkslemqb5h4g1")
const SOLDIER_PROJECTILE_TEXTURE = preload("res://assets/projectiles/soldier_projectile.png")

enum State {
	FOLLOW,
	WINDUP,
	BURST,
	RECOVERY,
}

var player: CharacterBody2D
var soldier_index: int = 0
var soldier_count: int = 1
var formation_offset: Vector2 = Vector2.ZERO
var shoot_cooldown: float = 0.0
var state: State = State.FOLLOW
var state_timer: float = 0.0
var burst_shots_remaining: int = 0
var burst_timer: float = 0.0
var hop_time: float = 0.0
var position_history: Array[Dictionary] = []
var history_time: float = 0.0
var current_target: Node2D

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	shoot_cooldown = randf_range(0.0, 0.35)
	update_formation_offset()


func _process(delta: float) -> void:
	if player == null or player.is_dead:
		return
	
	update_player_position_history(delta)
	
	match state:
		State.FOLLOW:
			process_follow(delta)
		State.WINDUP:
			process_windup(delta)
		State.BURST:
			process_burst(delta)
		State.RECOVERY:
			process_recovery(delta)


func configure(new_player: CharacterBody2D, new_index: int, new_count: int) -> void:
	player = new_player
	soldier_index = new_index
	soldier_count = max(new_count, 1)
	update_formation_offset()


func update_soldier_count(new_index: int, new_count: int) -> void:
	configure(player, new_index, new_count)


func update_formation_offset() -> void:
	var columns: int = mini(FOLLOW_COLUMN_COUNT, max(soldier_count, 1))
	var row: int = int(float(soldier_index) / float(columns))
	var column: int = soldier_index % columns
	var centered_column: float = float(column) - float(columns - 1) * 0.5
	var row_offset: float = 0.5 if row % 2 == 1 else 0.0
	var jitter := Vector2(randf_range(-2.0, 2.0), randf_range(-1.5, 1.5))
	formation_offset = Vector2(
		(centered_column + row_offset) * FOLLOW_COLUMN_SPACING,
		FOLLOW_BACK_OFFSET + float(row) * FOLLOW_ROW_SPACING
	) + jitter


func process_follow(delta: float) -> void:
	shoot_cooldown = max(shoot_cooldown - delta, 0.0)
	var moved := follow_player(delta)
	update_walk_animation(delta, moved)
	
	if shoot_cooldown > 0.0:
		return
	if global_position.distance_to(player.global_position) > NEAR_PLAYER_DISTANCE:
		return
	
	var target := get_nearest_enemy_in_range()
	if target == null:
		return
	
	current_target = target
	aim_at(current_target.global_position)
	state = State.WINDUP
	state_timer = SHOOT_WINDUP
	sprite.position.y = 0.0


func process_windup(delta: float) -> void:
	state_timer -= delta
	if is_instance_valid(current_target):
		aim_at(current_target.global_position)
	
	if state_timer <= 0.0:
		state = State.BURST
		burst_shots_remaining = BURST_SHOT_COUNT
		burst_timer = 0.0
		fire_at_current_target()


func process_burst(delta: float) -> void:
	if not is_instance_valid(current_target):
		enter_recovery()
		return
	
	aim_at(current_target.global_position)
	burst_timer += delta
	if burst_timer < BURST_SHOT_INTERVAL:
		return
	
	burst_timer = 0.0
	fire_at_current_target()
	
	if burst_shots_remaining <= 0:
		enter_recovery()


func process_recovery(delta: float) -> void:
	state_timer -= delta
	if state_timer <= 0.0:
		current_target = null
		shoot_cooldown = player.fire_interval
		state = State.FOLLOW


func enter_recovery() -> void:
	state = State.RECOVERY
	state_timer = SHOOT_RECOVERY
	burst_shots_remaining = 0


func follow_player(delta: float) -> bool:
	var target_position := get_delayed_player_position() + formation_offset
	var distance_to_target := global_position.distance_to(target_position)
	if distance_to_target <= 2.0:
		return false
	
	var distance_to_player := global_position.distance_to(player.global_position)
	var move_speed := CATCH_UP_SPEED if distance_to_player > CATCH_UP_DISTANCE else FOLLOW_SPEED
	global_position = global_position.move_toward(target_position, move_speed * delta)
	var move_direction := global_position.direction_to(target_position)
	if not move_direction.is_zero_approx():
		rotation = move_direction.angle() + PI / 2.0
	
	return true


func update_player_position_history(delta: float) -> void:
	history_time += delta
	position_history.append({
		"time": history_time,
		"position": player.global_position
	})
	
	var oldest_time := history_time - FOLLOW_DELAY - 0.2
	while position_history.size() > 2 and float(position_history[0].time) < oldest_time:
		position_history.pop_front()


func get_delayed_player_position() -> Vector2:
	if position_history.is_empty():
		return player.global_position
	
	var target_time := history_time - FOLLOW_DELAY
	for i in range(position_history.size() - 1, -1, -1):
		if float(position_history[i].time) <= target_time:
			return position_history[i].position
	
	return position_history[0].position


func update_walk_animation(delta: float, moved: bool) -> void:
	if not moved:
		sprite.position.y = 0.0
		return
	
	hop_time += delta
	sprite.position.y = -abs(sin(hop_time * TAU * 5.0)) * 1.5


func fire_at_current_target() -> void:
	if not is_instance_valid(current_target):
		return
	
	var direction := global_position.direction_to(current_target.global_position)
	if direction.is_zero_approx():
		return
	
	var damage_multiplier := 1.0
	if player.has_method("get_pet_damage_multiplier"):
		damage_multiplier = player.get_pet_damage_multiplier()
	var projectile_config := {
		"direction": direction,
		"damage": floor(player.attack_damage * 0.3125 * damage_multiplier),
		"splash_radius": 0.0,
		"max_piercing_hp": 1,
		"projectile_scale": 1.0 / 3.0,
		"projectile_texture": SOLDIER_PROJECTILE_TEXTURE,
		"fade_in_duration": 0.08,
	}
	var main := get_tree().current_scene
	if main and main.has_method("spawn_projectile"):
		main.spawn_projectile(projectile_config, global_position + direction * 14.0)
	else:
		var projectile = PROJECTILE.instantiate()
		get_tree().current_scene.add_child(projectile)
		projectile.launch(projectile_config)
		projectile.global_position = global_position + direction * 14.0
	spawn_muzzle_burst()
	burst_shots_remaining -= 1


func spawn_muzzle_burst() -> void:
	var main := get_tree().current_scene
	if main == null or not main.has_method("spawn_particle_burst"):
		return
	
	var muzzle_position := global_position + Vector2.UP.rotated(rotation) * 9.0
	main.spawn_particle_burst(main, muzzle_position, 6, Color(1.0, 0.76, 0.16, 1.0), 65.0, 0.08, Vector2(0.8, 1.3), true)


func aim_at(target_position: Vector2) -> void:
	var direction := global_position.direction_to(target_position)
	if direction.is_zero_approx():
		return
	
	rotation = direction.angle() + PI / 2.0


func get_nearest_enemy_in_range() -> Node2D:
	var nearest: Node2D = null
	var nearest_distance := SHOOT_RANGE * SHOOT_RANGE
	
	for enemy in RuntimeQuery.get_active_enemies(self):
		if not is_instance_valid(enemy):
			continue
		if enemy.has_method("is_damageable") and not enemy.is_damageable():
			continue
		
		var distance := global_position.distance_squared_to(enemy.global_position)
		if distance <= nearest_distance:
			nearest = enemy
			nearest_distance = distance
	
	return nearest
