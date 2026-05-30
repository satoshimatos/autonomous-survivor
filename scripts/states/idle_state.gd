extends EnemyState
class_name IdleState

@export var min_duration: float = 1.0
@export var max_duration: float = 2.0
@export var next_state_name: String = "ChaseState"

var duration_timer: float = 0.0


func enter() -> void:
	duration_timer = randf_range(min_duration, max_duration)


func update(delta: float) -> void:
	duration_timer -= delta
	if duration_timer <= 0.0 and next_state_name != "":
		request_transition(next_state_name)
