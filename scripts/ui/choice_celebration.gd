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
@export var ray_color: Color = Color(1.0, 1.0, 1.0, 0.11)
@export var bubble_color: Color = Color(1.0, 1.0, 1.0, 0.18)

var particles: Array[Dictionary] = []
var bursts: Array[Dictionary] = []
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
			"shape": randi_range(0, 2),
		})


func celebrate_pick(origin: Vector2, accent: Color) -> void:
	for i in range(34):
		var angle := randf() * TAU
		var speed := randf_range(160.0, 520.0)
		bursts.append({
			"position": origin,
			"velocity": Vector2.RIGHT.rotated(angle) * speed,
			"life": randf_range(0.38, 0.7),
			"max_life": 0.7,
			"radius": randf_range(3.0, 8.0),
			"spin": randf_range(-9.0, 9.0),
			"phase": randf() * TAU,
			"color": accent.lerp(palette[randi_range(0, palette.size() - 1)], randf_range(0.15, 0.55)),
			"shape": randi_range(0, 2),
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
	for i in range(bursts.size() - 1, -1, -1):
		var burst := bursts[i]
		var position: Vector2 = burst.position
		var velocity: Vector2 = burst.velocity
		position += velocity * delta
		velocity *= 1.0 - min(delta * 2.8, 0.82)
		velocity.y += 420.0 * delta
		burst.life = float(burst.life) - delta
		if float(burst.life) <= 0.0:
			bursts.remove_at(i)
			continue
		burst.position = position
		burst.velocity = velocity
	queue_redraw()


func _draw() -> void:
	var viewport_size := get_viewport_rect().size
	var center := viewport_size * 0.5
	var ray_count := 18
	var ray_length: float = maxf(viewport_size.x, viewport_size.y) * 0.78
	for i in range(ray_count):
		var angle := elapsed * 0.2 + TAU * float(i) / float(ray_count)
		var next_angle := angle + TAU / float(ray_count) * 0.42
		var color: Color = ray_color
		color.a *= 0.62 + sin(elapsed * 2.0 + float(i)) * 0.24
		draw_colored_polygon(PackedVector2Array([
			center,
			center + Vector2.RIGHT.rotated(angle) * ray_length,
			center + Vector2.RIGHT.rotated(next_angle) * ray_length,
		]), color)
	for i in range(4):
		var y := viewport_size.y * (0.20 + float(i) * 0.18) + sin(elapsed * 1.4 + float(i)) * 18.0
		draw_rect(Rect2(Vector2(0.0, y), Vector2(viewport_size.x, 18.0)), wave_color, true)
	for i in range(7):
		var bubble_position := Vector2(
			wrapf(elapsed * (18.0 + float(i) * 7.0) + float(i) * viewport_size.x * 0.17, -70.0, viewport_size.x + 70.0),
			viewport_size.y * (0.12 + float(i) * 0.12) + sin(elapsed * 1.6 + float(i) * 2.0) * 22.0
		)
		draw_circle(bubble_position, 18.0 + float(i % 3) * 8.0, bubble_color)
	for particle in particles:
		draw_confetti_particle(particle, 1.0)
	for burst in bursts:
		var alpha: float = clampf(float(burst.life) / maxf(float(burst.max_life), 0.001), 0.0, 1.0)
		draw_confetti_particle(burst, alpha)


func draw_confetti_particle(particle: Dictionary, alpha: float) -> void:
	var position: Vector2 = particle.position
	var radius := float(particle.radius)
	var color: Color = particle.color
	color.a *= alpha
	var rotation := elapsed * float(particle.spin) + float(particle.phase)
	match int(particle.get("shape", 0)):
		0:
			var tilt := Vector2.RIGHT.rotated(rotation) * radius * 2.2
			draw_line(position - tilt, position + tilt, color, max(radius, 1.0))
		1:
			draw_circle(position, radius * 1.15, color)
		_:
			var side := Vector2.RIGHT.rotated(rotation) * radius * 1.8
			var up := Vector2.UP.rotated(rotation) * radius * 1.2
			draw_colored_polygon(PackedVector2Array([position - side - up, position + side - up, position + side + up, position - side + up]), color)
