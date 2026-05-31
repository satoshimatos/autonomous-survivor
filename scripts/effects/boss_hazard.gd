extends Area2D

var radius: float = 72.0
var warning_time: float = 0.9
var active_time: float = 0.45
var damage: int = 3
var age: float = 0.0
var has_fired: bool = false

@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func configure(hazard_radius: float, warning_duration: float, active_duration: float, damage_amount: int) -> void:
	radius = hazard_radius
	warning_time = warning_duration
	active_time = active_duration
	damage = damage_amount
	if is_node_ready():
		apply_shape_radius()


func _ready() -> void:
	apply_shape_radius()


func apply_shape_radius() -> void:
	var circle := collision_shape.shape as CircleShape2D
	if circle != null:
		circle.radius = radius


func _process(delta: float) -> void:
	age += delta
	if not has_fired and age >= warning_time:
		has_fired = true
		damage_overlapping_player()
	if age >= warning_time + active_time:
		queue_free()
		return
	queue_redraw()


func damage_overlapping_player() -> void:
	for body in get_overlapping_bodies():
		if body.is_in_group("Player") and body.has_method("hit"):
			body.hit(damage)


func _draw() -> void:
	var warning_progress: float = clamp(age / max(warning_time, 0.001), 0.0, 1.0)
	if not has_fired:
		var alpha: float = 0.22 + warning_progress * 0.42
		draw_circle(Vector2.ZERO, radius, Color(1.0, 0.08, 0.03, alpha))
		draw_arc(Vector2.ZERO, radius, 0.0, TAU, 64, Color(1.0, 0.78, 0.08, 0.85), 3.0 + warning_progress * 5.0, true)
		return
	
	var active_progress: float = clamp((age - warning_time) / max(active_time, 0.001), 0.0, 1.0)
	var alpha: float = 0.65 * (1.0 - active_progress)
	draw_circle(Vector2.ZERO, radius, Color(1.0, 0.16, 0.04, alpha))
	draw_arc(Vector2.ZERO, radius * (0.72 + active_progress * 0.28), 0.0, TAU, 64, Color(1.0, 0.95, 0.2, alpha), 8.0, true)
