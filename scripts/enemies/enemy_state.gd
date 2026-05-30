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


func request_transition(state_name: String) -> void:
	transition_requested.emit(state_name)
