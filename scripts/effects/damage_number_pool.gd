extends Node2D

const POOL_SIZE: int = 96
const LIFETIME: float = 1.0
const GRAVITY: float = 120.0
const INITIAL_Y_SPEED: float = -65.0
const X_SPEED_RANGE: Vector2 = Vector2(-45.0, 45.0)

var labels: Array[Label] = []
var active: Array[bool] = []
var ages: Array[float] = []
var velocities: Array[Vector2] = []


func _ready() -> void:
	z_index = 10
	
	for i in range(POOL_SIZE):
		var label := Label.new()
		label.visible = false
		label.add_theme_font_size_override("font_size", 18)
		label.add_theme_color_override("font_color", Color(1, 0.95, 0.35, 1))
		label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
		label.add_theme_constant_override("shadow_offset_x", 1)
		label.add_theme_constant_override("shadow_offset_y", 1)
		add_child(label)
		
		labels.append(label)
		active.append(false)
		ages.append(0.0)
		velocities.append(Vector2.ZERO)


func show_damage(world_position: Vector2, damage: int) -> void:
	var index := get_available_index()
	var label := labels[index]
	
	active[index] = true
	ages[index] = 0.0
	velocities[index] = Vector2(randf_range(X_SPEED_RANGE.x, X_SPEED_RANGE.y), INITIAL_Y_SPEED)
	
	label.text = "-%s" % damage
	label.global_position = world_position
	label.modulate = Color.WHITE
	label.visible = true


func get_available_index() -> int:
	for i in range(active.size()):
		if not active[i]:
			return i
	
	var oldest_index := 0
	var oldest_age := ages[0]
	for i in range(1, ages.size()):
		if ages[i] > oldest_age:
			oldest_age = ages[i]
			oldest_index = i
	
	return oldest_index


func _process(delta: float) -> void:
	for i in range(labels.size()):
		if not active[i]:
			continue
		
		ages[i] += delta
		if ages[i] >= LIFETIME:
			active[i] = false
			labels[i].visible = false
			continue
		
		velocities[i].y += GRAVITY * delta
		labels[i].global_position += velocities[i] * delta
		labels[i].modulate.a = 1.0 - ages[i] / LIFETIME
