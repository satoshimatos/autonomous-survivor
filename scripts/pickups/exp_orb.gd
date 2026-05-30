extends Area2D

const MAGNET_SPEED: float = 300.0
const BASE_RADIUS: float = 5.0
const MAX_RADIUS: float = 18.0

var exp_value: int = 1
var radius: float = BASE_RADIUS
var base_radius: float = BASE_RADIUS
var base_visual_scale: float = 1.0
var crystal_texture: Texture2D
var magnet_active: bool = false
var player: Node2D


func _process(delta: float) -> void:
	if magnet_active and player:
		global_position = global_position.move_toward(player.global_position, MAGNET_SPEED * delta)


func configure(value: int, orb_radius: float, texture: Texture2D, visual_scale: float = 1.0) -> void:
	exp_value = value
	radius = orb_radius
	base_radius = orb_radius
	base_visual_scale = visual_scale
	crystal_texture = texture
	apply_visuals()


func merge_exp(additional_value: int) -> void:
	exp_value += additional_value
	radius = min(radius + 1.0, MAX_RADIUS)
	apply_visuals()


func apply_visuals() -> void:
	var collision_shape: CircleShape2D = $CollisionShape2D.shape
	if not collision_shape.resource_local_to_scene:
		collision_shape = collision_shape.duplicate()
		collision_shape.resource_local_to_scene = true
		$CollisionShape2D.shape = collision_shape
	
	collision_shape.radius = radius
	$CrystalSprite.texture = crystal_texture
	$CrystalSprite.scale = Vector2.ONE * base_visual_scale * (radius / base_radius)


func set_magnet_active(active: bool, target: Node2D = null) -> void:
	magnet_active = active
	player = target


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.add_exp(body.get_exp_value(exp_value))
		var main: Node = get_tree().current_scene
		if main and main.has_method("spawn_exp_pickup_burst"):
			main.call_deferred("spawn_exp_pickup_burst")
		queue_free()
