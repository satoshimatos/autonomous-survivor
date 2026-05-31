extends Area2D

signal defeated(enemy_position: Vector2, exp_drop_count: int, exp_drop_min_tier: int, death_payload: Dictionary)

@export var base_speed: float = 50.0
@export var health: int = 14
@export var contact_damage: int = 1
@export var exp_drop_count: int = 1
@export var exp_drop_min_tier: int = 1
@export var movement_style: String = "chase"

var speed: float = 50.0
var player: CharacterBody2D
var main: Node2D
var is_defeated: bool = false
var hit_flash_timer: float = 0.0
var base_modulate: Color = Color.WHITE
var base_health: int = 14
var max_health: int = 14
var variant_color: Color = Color.WHITE
var variant_scale: float = 1.0
var movement_seed: float = 0.0
var movement_timer: float = 0.0
var slow_timer: float = 0.0
var slow_multiplier: float = 1.0
var death_payload: Dictionary = {}

@onready var mesh_instance: MeshInstance2D = $MeshInstance2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	main = get_tree().current_scene
	speed = base_speed
	base_health = health
	max_health = health
	movement_seed = randf() * TAU
	apply_variant_visuals()
	base_modulate = mesh_instance.modulate


func _process(delta: float) -> void:
	update_status_effects(delta)
	update_hit_flash(delta)
	
	if player:
		position += get_movement_vector(delta) * speed * get_status_speed_multiplier() * delta
	
	var bodies = get_overlapping_bodies()
	if bodies.size() > 0:
		var body = bodies[0]
		if body.is_in_group("Player"):
			var damage_amount := contact_damage
			if main and main.has_method("get_scaled_enemy_contact_damage"):
				damage_amount = main.get_scaled_enemy_contact_damage(contact_damage)
			
			body.hit(damage_amount)


func configure_variant(config: Dictionary) -> void:
	base_speed = float(config.get("speed", base_speed))
	speed = base_speed
	health = int(config.get("health", health))
	contact_damage = int(config.get("contact_damage", contact_damage))
	exp_drop_count = int(config.get("exp_drop_count", exp_drop_count))
	exp_drop_min_tier = int(config.get("exp_drop_min_tier", exp_drop_min_tier))
	movement_style = String(config.get("movement_style", movement_style))
	variant_color = config.get("color", Color.WHITE) as Color
	variant_scale = float(config.get("scale", 1.0))
	death_payload = (config.get("death_payload", {}) as Dictionary).duplicate(true)
	if config.has("elite_affix"):
		death_payload["elite_affix"] = String(config.get("elite_affix", ""))
	if is_node_ready():
		base_health = health
		max_health = health
		apply_variant_visuals()
		base_modulate = mesh_instance.modulate


func apply_variant_visuals() -> void:
	if variant_color != Color.WHITE:
		mesh_instance.modulate = variant_color
	if not is_equal_approx(variant_scale, 1.0):
		mesh_instance.scale = Vector2.ONE * variant_scale
		collision_shape.scale = Vector2.ONE * variant_scale


func get_movement_vector(delta: float) -> Vector2:
	movement_timer += delta
	var direction := global_position.direction_to(player.global_position)
	match movement_style:
		"zigzag":
			return direction.rotated(sin(movement_timer * 4.0 + movement_seed) * 0.65).normalized()
		"weaver":
			return direction.rotated(sin(movement_timer * 7.0 + movement_seed) * 0.35).normalized()
		"drifter":
			return direction.rotated(sin(movement_timer * 1.6 + movement_seed) * 1.1).normalized()
		"sprinter":
			var pulse: float = 0.72 + max(0.0, sin(movement_timer * 3.0 + movement_seed)) * 0.75
			return direction * pulse
		"orbiter":
			return direction.rotated(0.9).lerp(direction, 0.42).normalized()
		"stalker":
			var distance := global_position.distance_to(player.global_position)
			if distance < 120.0:
				return direction * 1.45
			return direction * 0.72
		_:
			return direction


func apply_slow(duration: float, multiplier: float) -> void:
	slow_timer = max(slow_timer, duration)
	slow_multiplier = min(slow_multiplier, clamp(multiplier, 0.05, 1.0))
	if is_node_ready():
		mesh_instance.modulate = base_modulate.lerp(Color(0.35, 0.85, 1.0, 1.0), 0.45)


func update_status_effects(delta: float) -> void:
	if slow_timer <= 0.0:
		return
	
	slow_timer = max(slow_timer - delta, 0.0)
	if slow_timer <= 0.0:
		slow_multiplier = 1.0
		if hit_flash_timer <= 0.0:
			mesh_instance.modulate = base_modulate


func get_status_speed_multiplier() -> float:
	return slow_multiplier if slow_timer > 0.0 else 1.0


func hit(damage: float = 10.0, show_number: bool = true) -> int:
	if is_defeated:
		return 0
	if not is_damageable():
		return 0
	
	var actual_damage: int = mini(floori(damage), health)
	health -= actual_damage
	
	if show_number and main and main.has_method("show_damage_number"):
		main.show_damage_number(global_position, actual_damage)
		start_hit_flash()
	
	if health <= 0:
		is_defeated = true
		defeated.emit(global_position, exp_drop_count, exp_drop_min_tier, death_payload)
		queue_free()
	
	return actual_damage


func is_damageable() -> bool:
	if main and main.has_method("is_position_in_arena"):
		return main.is_position_in_arena(global_position)
	
	return true


func set_global_speed_scale(global_speed_scale: float) -> void:
	speed = base_speed * global_speed_scale


func apply_speed_multiplier(multiplier: float) -> void:
	speed *= multiplier


func apply_health_bonus(total_bonus_percent: float) -> void:
	var previous_max_health := max_health
	max_health = int(ceil(float(base_health) * (1.0 + total_bonus_percent)))
	var health_gain := max_health - previous_max_health
	if health_gain > 0:
		health += health_gain


func start_hit_flash() -> void:
	hit_flash_timer = 0.08
	mesh_instance.modulate = Color.WHITE


func update_hit_flash(delta: float) -> void:
	if hit_flash_timer <= 0.0:
		return
	
	hit_flash_timer -= delta
	if hit_flash_timer <= 0.0:
		mesh_instance.modulate = base_modulate
