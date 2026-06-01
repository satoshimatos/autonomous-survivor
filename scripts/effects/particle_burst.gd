extends Node2D

var particle_positions: Array[Vector2] = []
var particle_velocities: Array[Vector2] = []
var particle_sizes: Array[float] = []
var particle_spin: Array[float] = []
var lifetime: float = 0.5
var age: float = 0.0
var shrink: bool = false
var particle_color: Color = Color.RED
var is_active: bool = true


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func configure(count: int, color: Color, speed: float, duration: float, size_range: Vector2, should_shrink: bool) -> void:
	is_active = true
	visible = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	age = 0.0
	particle_color = color
	lifetime = duration
	shrink = should_shrink
	particle_positions.clear()
	particle_velocities.clear()
	particle_sizes.clear()
	particle_spin.clear()
	
	for i in range(count):
		var direction: Vector2 = Vector2.RIGHT.rotated(randf_range(0.0, TAU))
		particle_positions.append(Vector2.ZERO)
		particle_velocities.append(direction * randf_range(speed * 0.45, speed * 1.15))
		particle_sizes.append(randf_range(size_range.x, size_range.y))
		particle_spin.append(randf_range(-PI, PI))


func _process(delta: float) -> void:
	if not is_active:
		return
	
	age += delta
	
	for i in range(particle_positions.size()):
		particle_positions[i] += particle_velocities[i] * delta
	
	if age >= lifetime:
		release()
		return
	queue_redraw()


func release() -> void:
	if not is_active:
		return
	is_active = false
	visible = false
	if is_in_group("ParticleBurst"):
		remove_from_group("ParticleBurst")
	var main := get_tree().current_scene
	if main and main.has_method("recycle_particle_burst"):
		main.recycle_particle_burst(self)
	else:
		queue_free()


func _draw() -> void:
	var progress: float = clamp(age / lifetime, 0.0, 1.0)
	var size_scale: float = 1.0 - progress if shrink else 1.0
	var alpha := 1.0 - progress
	
	for i in range(particle_positions.size()):
		var radius := particle_sizes[i] * size_scale
		var color := particle_color
		color.a *= alpha
		var outline := Color(0.02, 0.015, 0.01, color.a)
		var spark := color.lightened(0.35)
		draw_circle(particle_positions[i], radius + 1.5, outline)
		draw_circle(particle_positions[i], radius, color)
		var streak := Vector2.RIGHT.rotated(particle_spin[i]) * radius * 1.5
		draw_line(particle_positions[i] - streak * 0.35, particle_positions[i] + streak, spark, max(radius * 0.35, 1.0), true)
