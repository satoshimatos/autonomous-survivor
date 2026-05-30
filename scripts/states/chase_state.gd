extends EnemyState
class_name ChaseState

@export var use_duration: bool = false
@export var min_duration: float = 2.0
@export var max_duration: float = 4.0
@export var next_state_name: String = ""

var duration_timer: float = 0.0


func enter() -> void:
	if use_duration:
		duration_timer = randf_range(min_duration, max_duration)


func update(delta: float) -> void:
	if actor == null:
		return
	
	var player := actor.get_tree().get_first_node_in_group("Player") as Node2D
	if player:
		var speed: float = actor.speed if "speed" in actor else 0.0
		var direction := actor.global_position.direction_to(player.global_position)
		actor.position += direction * speed * delta
	
	if not use_duration:
		return
	
	duration_timer -= delta
	if duration_timer <= 0.0 and next_state_name != "":
		request_transition(next_state_name)
