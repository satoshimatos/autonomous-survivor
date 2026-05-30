extends Node2D

@export var area_center: Vector2 = Vector2(576, 324)
@export var area_size: Vector2 = Vector2(1600, 1000)

var specks: Array[Dictionary] = []
var scuffs: Array[Dictionary] = []
var patches: Array[Dictionary] = []


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 26052026
	
	for i in range(520):
		specks.append({
			"position": random_floor_position(rng),
			"radius": rng.randf_range(1.5, 3.5),
			"alpha": rng.randf_range(0.12, 0.22),
		})
	
	for i in range(70):
		scuffs.append({
			"position": random_floor_position(rng),
			"angle": rng.randf_range(0.0, TAU),
			"length": rng.randf_range(24.0, 68.0),
			"alpha": rng.randf_range(0.16, 0.28),
		})
	
	for i in range(24):
		patches.append({
			"position": random_floor_position(rng),
			"size": Vector2(rng.randf_range(22.0, 58.0), rng.randf_range(10.0, 28.0)),
			"angle": rng.randf_range(0.0, TAU),
			"alpha": rng.randf_range(0.08, 0.14),
		})
	
	queue_redraw()


func random_floor_position(rng: RandomNumberGenerator) -> Vector2:
	var half_size := area_size / 2.0
	return Vector2(
		rng.randf_range(area_center.x - half_size.x, area_center.x + half_size.x),
		rng.randf_range(area_center.y - half_size.y, area_center.y + half_size.y)
	)


func _draw() -> void:
	var half_size := area_size / 2.0
	var top_left := area_center - half_size
	var bottom_right := area_center + half_size
	var grid_color := Color(0.44, 0.44, 0.44, 0.22)
	
	for x in range(int(top_left.x), int(bottom_right.x) + 1, 128):
		draw_line(Vector2(x, top_left.y), Vector2(x, bottom_right.y), grid_color, 1.0)
	
	for y in range(int(top_left.y), int(bottom_right.y) + 1, 128):
		draw_line(Vector2(top_left.x, y), Vector2(bottom_right.x, y), grid_color, 1.0)
	
	for patch in patches:
		draw_set_transform(patch.position, patch.angle, Vector2.ONE)
		draw_rect(Rect2(-patch.size / 2.0, patch.size), Color(0.39, 0.39, 0.39, patch.alpha), true)
	
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	
	for speck in specks:
		draw_circle(speck.position, speck.radius, Color(0.35, 0.35, 0.35, speck.alpha))
	
	for scuff in scuffs:
		var direction := Vector2.RIGHT.rotated(scuff.angle)
		var start: Vector2 = scuff.position - direction * scuff.length * 0.5
		var end: Vector2 = scuff.position + direction * scuff.length * 0.5
		draw_line(start, end, Color(0.31, 0.31, 0.31, scuff.alpha), 2.0)
