extends Camera2D

var shake_timer: float = 0.0
var shake_duration: float = 0.15
var shake_strength: float = 4.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT


func _process(delta: float) -> void:
	if shake_timer <= 0.0:
		offset = Vector2.ZERO
		return
	
	shake_timer = max(shake_timer - delta, 0.0)
	var strength := shake_strength * (shake_timer / shake_duration)
	offset = Vector2(randf_range(-strength, strength), randf_range(-strength, strength))
	
	if shake_timer <= 0.0:
		offset = Vector2.ZERO


func start_shake(duration: float = 0.15, strength: float = 4.0) -> void:
	shake_duration = duration
	shake_strength = strength
	shake_timer = duration
