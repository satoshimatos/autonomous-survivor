extends Label

const FLOAT_DISTANCE: float = 36.0
const DURATION: float = 1.0

var elapsed: float = 0.0
var start_position: Vector2


func configure(world_position: Vector2, healed_amount: int) -> void:
	global_position = world_position
	start_position = global_position
	text = "+%s" % healed_amount
	modulate = Color(0.2, 1.0, 0.25, 1.0)


func _process(delta: float) -> void:
	elapsed += delta
	var progress: float = clamp(elapsed / DURATION, 0.0, 1.0)
	global_position = start_position + Vector2.UP * FLOAT_DISTANCE * progress
	modulate.a = 1.0 - progress
	
	if progress >= 1.0:
		queue_free()
