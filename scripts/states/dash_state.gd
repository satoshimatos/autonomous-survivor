extends EnemyState
class_name DashState

@export var duration: float = 1.25
@export var fallback_distance: float = 750.0
@export var next_state_name: String = "IdleState"

var direction: Vector2 = Vector2.RIGHT
var remaining_distance: float = 0.0
var dash_speed: float = 0.0


func enter() -> void:
	direction = state_machine.blackboard.get("dash_direction", Vector2.RIGHT) as Vector2
	if direction.is_zero_approx():
		direction = Vector2.RIGHT
	
	remaining_distance = float(state_machine.blackboard.get("dash_distance", fallback_distance))
	dash_speed = remaining_distance / max(duration, 0.001)


func update(delta: float) -> void:
	if actor == null:
		return
	
	var travel_distance: float = min(dash_speed * delta, remaining_distance)
	var previous_position := actor.global_position
	move_actor_to(actor.global_position + direction * travel_distance)
	remaining_distance -= travel_distance
	if actor.global_position.distance_squared_to(previous_position + direction * travel_distance) > 0.01:
		remaining_distance = 0.0
	if actor.has_method("clamp_to_arena") and bool(actor.clamp_to_arena()):
		remaining_distance = 0.0
	
	if remaining_distance <= 0.0 and next_state_name != "":
		request_transition(next_state_name)
