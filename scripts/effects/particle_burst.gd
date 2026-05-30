extends Node2D

var particle_positions: Array[Vector2] = []
var particle_velocities: Array[Vector2] = []
var particle_sizes: Array[float] = []
var lifetime: float = 0.5
var age: float = 0.0
var shrink: bool = false
var particle_color: Color = Color.RED


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func configure(count: int, color: Color, speed: float, duration: float, size_range: Vector2, should_shrink: bool) -> void:
	particle_color = color
	lifetime = duration
	shrink = should_shrink
	particle_positions.clear()
	particle_velocities.clear()
	particle_sizes.clear()
	
	for i in range(count):
		var direction: Vector2 = Vector2.RIGHT.rotated(randf_range(0.0, TAU))
		particle_positions.append(Vector2.ZERO)
		particle_velocities.append(direction * speed)
		particle_sizes.append(randf_range(size_range.x, size_range.y))


func _process(delta: float) -> void:
	age += delta
	
	for i in range(particle_positions.size()):
		particle_positions[i] += particle_velocities[i] * delta
	
	if age >= lifetime:
		queue_free()
	else:
		queue_redraw()


func _draw() -> void:
	var progress: float = clamp(age / lifetime, 0.0, 1.0)
	var size_scale: float = 1.0 - progress if shrink else 1.0
	
	for i in range(particle_positions.size()):
		draw_circle(particle_positions[i], particle_sizes[i] * size_scale, particle_color)
