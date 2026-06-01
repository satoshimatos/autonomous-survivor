extends Node2D

@export var arena_center: Vector2 = Vector2(576, 324)
@export var drift_speed: Vector2 = Vector2(9.0, 3.5)
@export var parallax_strength: float = 0.08

var age: float = 0.0
var sprites: Array[Sprite2D] = []


func _ready() -> void:
	for child in get_children():
		if child is Sprite2D:
			sprites.append(child)


func _process(delta: float) -> void:
	age += delta
	var player := get_tree().get_first_node_in_group("Player")
	var parallax_offset := Vector2.ZERO
	if player is Node2D:
		parallax_offset = (player.global_position - arena_center) * parallax_strength
	
	for i in range(sprites.size()):
		var sprite := sprites[i]
		var loop_size := Vector2(900.0, 520.0)
		var phase := float(i) * 0.37
		var drift := Vector2(
			fposmod(age * drift_speed.x + phase * loop_size.x, loop_size.x) - loop_size.x * 0.5,
			sin(age * 0.18 + phase * TAU) * 76.0 + age * drift_speed.y
		)
		sprite.global_position = arena_center + sprite.get_meta("base_offset", Vector2.ZERO) + drift + parallax_offset
