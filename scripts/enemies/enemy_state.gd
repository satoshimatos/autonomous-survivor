extends Node
class_name EnemyState

signal transition_requested(state_name: String)

var actor: Node2D
var state_machine: Node


func setup(new_actor: Node2D, new_state_machine: Node) -> void:
	actor = new_actor
	state_machine = new_state_machine


func enter() -> void:
	pass


func exit() -> void:
	pass


func update(_delta: float) -> void:
	pass


func move_actor_to(target_position: Vector2) -> void:
	if actor == null:
		return
	var main := actor.get_tree().current_scene
	if main and main.has_method("resolve_actor_position"):
		actor.global_position = main.resolve_actor_position(actor.global_position, target_position, EnemyGeometry.get_collision_radius(actor as Area2D) if actor is Area2D else 24.0)
	else:
		actor.global_position = target_position


func request_transition(state_name: String) -> void:
	transition_requested.emit(state_name)
