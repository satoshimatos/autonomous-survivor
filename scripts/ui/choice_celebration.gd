extends Control

@export var palette: Array[Color] = [
	Color(1.0, 0.28, 0.22, 0.85),
	Color(1.0, 0.86, 0.18, 0.9),
	Color(0.18, 0.95, 1.0, 0.85),
	Color(0.52, 1.0, 0.28, 0.85),
	Color(0.96, 0.36, 1.0, 0.85),
]
@export var particle_count: int = 90
@export var wave_color: Color = Color(1.0, 0.9, 0.2, 0.18)

var particles: Array[Dictionary] = []
var elapsed: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	seed_particles()


func seed_particles() -> void:
	particles.clear()
	var viewport_size := get_viewport_rect().size
	for i in range(particle_count):
		particles.append({
			"position": Vector2(randf_range(0.0, viewport_size.x), randf_range(-viewport_size.y * 0.25, viewport_size.y)),
			"velocity": Vector2(randf_range(-28.0, 28.0), randf_range(32.0, 118.0)),
			"radius": randf_range(2.0, 5.0),
			"spin": randf_range(-4.0, 4.0),
			"phase": randf() * TAU,
			"color": palette[randi_range(0, palette.size() - 1)],
		})


func _process(delta: float) -> void:
	var viewport_size := get_viewport_rect().size
	elapsed += delta
	for particle in particles:
		var position: Vector2 = particle.position
		var velocity: Vector2 = particle.velocity
		position += velocity * delta
		position.x += sin(elapsed * 2.0 + float(particle.phase)) * 22.0 * delta
		if position.y > viewport_size.y + 18.0:
			position.y = randf_range(-90.0, -12.0)
			position.x = randf_range(0.0, viewport_size.x)
		particle.position = position
	queue_redraw()


func _draw() -> void:
	var viewport_size := get_viewport_rect().size
	for i in range(4):
		var y := viewport_size.y * (0.20 + float(i) * 0.18) + sin(elapsed * 1.4 + float(i)) * 18.0
		draw_rect(Rect2(Vector2(0.0, y), Vector2(viewport_size.x, 18.0)), wave_color, true)
	for particle in particles:
		var position: Vector2 = particle.position
		var radius := float(particle.radius)
		var color: Color = particle.color
		var tilt := Vector2.RIGHT.rotated(elapsed * float(particle.spin) + float(particle.phase)) * radius * 2.2
		draw_line(position - tilt, position + tilt, color, radius)
