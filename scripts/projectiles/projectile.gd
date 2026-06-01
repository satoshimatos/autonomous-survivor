extends Area2D

const COLLISION_RADIUS: float = 6.0
const DEFAULT_SPEED: float = 500.0
const POOLED_POSITION: Vector2 = Vector2(-100000.0, -100000.0)

var speed: float = DEFAULT_SPEED
var direction: Vector2
var damage: float = 10.0
var splash_radius: float = 0.0
var splash_damage_multiplier: float = 1.0
var critical_chance: float = 0.0
var critical_multiplier: float = 1.0
var max_piercing_hp: int = 1
var piercing_hp: int = 1
var hit_enemies := {}
var projectile_scale: float = 1.0
var projectile_texture: Texture2D
var fade_in_duration: float = 0.0
var fade_in_age: float = 0.0
var default_projectile_texture: Texture2D
var is_active: bool = true

@onready var projectile_sprite: Sprite2D = $ProjectileSprite
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var lifetime_timer: Timer = $Timer


func _ready() -> void:
	default_projectile_texture = projectile_sprite.texture
	prepare_for_pool()


func launch(config: Dictionary) -> void:
	direction = config.get("direction", Vector2.RIGHT) as Vector2
	if direction.is_zero_approx():
		direction = Vector2.RIGHT
	damage = float(config.get("damage", 10.0))
	splash_radius = float(config.get("splash_radius", 0.0))
	splash_damage_multiplier = float(config.get("splash_damage_multiplier", 1.0))
	critical_chance = clamp(float(config.get("critical_chance", 0.0)), 0.0, 1.0)
	critical_multiplier = max(float(config.get("critical_multiplier", 1.0)), 1.0)
	max_piercing_hp = int(config.get("max_piercing_hp", 1))
	speed = float(config.get("speed", DEFAULT_SPEED))
	projectile_scale = float(config.get("projectile_scale", 1.0))
	projectile_texture = config.get("projectile_texture", null) as Texture2D
	fade_in_duration = float(config.get("fade_in_duration", 0.0))
	reset_for_launch()


func reset_for_launch() -> void:
	is_active = true
	visible = true
	process_mode = Node.PROCESS_MODE_INHERIT
	monitoring = true
	monitorable = true
	if collision_shape:
		collision_shape.disabled = false
	hit_enemies.clear()
	piercing_hp = max_piercing_hp
	fade_in_age = 0.0
	scale = Vector2.ONE * projectile_scale
	rotation = direction.angle() + PI / 2.0
	modulate = Color.WHITE
	projectile_sprite.texture = projectile_texture if projectile_texture else default_projectile_texture
	if fade_in_duration > 0.0:
		modulate.a = 0.0
	if lifetime_timer:
		lifetime_timer.start()


func _process(delta: float) -> void:
	if not is_active:
		return
	var previous_position: Vector2 = global_position
	var next_position: Vector2 = global_position + direction * speed * delta
	check_swept_enemy_hits(previous_position, next_position)
	if is_active and not is_queued_for_deletion():
		global_position = next_position
	update_fade_in(delta)
	queue_redraw()


func update_fade_in(delta: float) -> void:
	if fade_in_duration <= 0.0 or modulate.a >= 1.0:
		return
	
	fade_in_age += delta
	modulate.a = clamp(fade_in_age / fade_in_duration, 0.0, 1.0)


func _on_area_entered(area: Area2D) -> void:
	if not is_active:
		return
	hit_enemy(area, global_position)


func hit_enemy(area: Area2D, hit_position: Vector2) -> void:
	if not is_active:
		return
	if not area.is_in_group("Enemy"):
		return
	if hit_enemies.has(area):
		return
	
	hit_enemies[area] = true
	var hit_damage := get_damage_for_piercing_state()
	piercing_hp -= 1
	var is_final_hit := piercing_hp <= 0
	global_position = hit_position
	
	if splash_radius > 0.0:
		spawn_splash(hit_damage * splash_damage_multiplier)
	else:
		var actual_damage: int = area.hit(hit_damage)
		record_player_damage(actual_damage)
	
	if is_final_hit:
		release()


func check_swept_enemy_hits(start_position: Vector2, end_position: Vector2) -> void:
	while piercing_hp > 0:
		var closest_enemy: Area2D = null
		var closest_hit_position: Vector2 = end_position
		var closest_distance_along_segment: float = INF
		
		for enemy in get_tree().get_nodes_in_group("Enemy"):
			if not is_instance_valid(enemy) or not enemy is Area2D:
				continue
			if hit_enemies.has(enemy):
				continue
			if enemy.has_method("is_damageable") and not enemy.is_damageable():
				continue
			
			var hit_position: Vector2 = get_segment_closest_point(start_position, end_position, enemy.global_position)
			var hit_radius: float = COLLISION_RADIUS * projectile_scale + EnemyGeometry.get_collision_radius(enemy)
			if hit_position.distance_to(enemy.global_position) > hit_radius:
				continue
			
			var distance_along_segment: float = start_position.distance_squared_to(hit_position)
			if distance_along_segment < closest_distance_along_segment:
				closest_enemy = enemy
				closest_hit_position = hit_position
				closest_distance_along_segment = distance_along_segment
		
		if closest_enemy == null:
			return
		
		hit_enemy(closest_enemy, closest_hit_position)
		if not is_active or is_queued_for_deletion():
			return


func get_segment_closest_point(start_position: Vector2, end_position: Vector2, point: Vector2) -> Vector2:
	var segment: Vector2 = end_position - start_position
	var segment_length_squared: float = segment.length_squared()
	if is_zero_approx(segment_length_squared):
		return start_position
	
	var distance_ratio: float = clamp((point - start_position).dot(segment) / segment_length_squared, 0.0, 1.0)
	return start_position + segment * distance_ratio


func _on_timer_timeout() -> void:
	release()


func release() -> void:
	if not is_active:
		return
	var main := get_tree().current_scene
	if main and main.has_method("recycle_projectile"):
		main.recycle_projectile(self)
	else:
		prepare_for_pool()
		queue_free()


func prepare_for_pool() -> void:
	is_active = false
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED
	monitoring = false
	monitorable = false
	if collision_shape:
		collision_shape.disabled = true
	if lifetime_timer:
		lifetime_timer.stop()
	hit_enemies.clear()
	global_position = POOLED_POSITION
	queue_redraw()


func _draw() -> void:
	if not is_active:
		return
	var tail := Vector2.DOWN * 38.0
	draw_line(Vector2.ZERO, tail, Color(0.02, 0.015, 0.01, 0.62), 9.0, true)
	draw_line(Vector2.ZERO, tail * 0.86, Color(1.0, 0.7, 0.08, 0.72), 5.0, true)


func spawn_splash(splash_damage: float) -> void:
	var enemies := get_splash_enemies()
	get_tree().current_scene.call_deferred("_spawn_splash_area", global_position, splash_radius, splash_damage, enemies)


func record_player_damage(amount: int) -> void:
	if amount <= 0:
		return
	
	var main := get_tree().current_scene
	if main and main.has_method("record_player_damage"):
		main.record_player_damage(amount)


func get_damage_for_piercing_state() -> float:
	var spent_hp: int = max(max_piercing_hp - piercing_hp, 0)
	var damage_multiplier: float = max(1.0 - float(spent_hp) * 0.3, 0.15)
	var crit_multiplier := critical_multiplier if randf() <= critical_chance else 1.0
	return damage * damage_multiplier * crit_multiplier


func get_splash_enemies() -> Array[Area2D]:
	var enemies: Array[Area2D] = []
	var seen_enemies := {}
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		if not is_instance_valid(enemy):
			continue
		if seen_enemies.has(enemy):
			continue
		if enemy.has_method("is_damageable") and not enemy.is_damageable():
			continue
		
		var overlap_radius: float = splash_radius + EnemyGeometry.get_collision_radius(enemy)
		if global_position.distance_to(enemy.global_position) <= overlap_radius:
			enemies.append(enemy)
			seen_enemies[enemy] = true
	
	return enemies
