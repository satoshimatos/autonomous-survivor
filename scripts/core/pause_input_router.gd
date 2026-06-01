class_name PauseInputRouter
extends Node

signal pause_requested
signal restart_requested


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_game"):
		pause_requested.emit()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("restart_run"):
		restart_requested.emit()
		get_viewport().set_input_as_handled()
