extends Node
class_name StateMachine

@export var initial_state_name: String = "ChaseState"

var actor: Node2D
var current_state: EnemyState
var states: Dictionary = {}
var blackboard: Dictionary = {}


func setup(new_actor: Node2D) -> void:
	actor = new_actor
	states.clear()
	
	for child in get_children():
		if child is EnemyState:
			var state := child as EnemyState
			states[state.name] = state
			state.setup(actor, self)
			if not state.transition_requested.is_connected(_on_state_transition_requested):
				state.transition_requested.connect(_on_state_transition_requested)
	
	if initial_state_name != "":
		transition_to(initial_state_name)


func update(delta: float) -> void:
	if current_state:
		current_state.update(delta)


func transition_to(state_name: String) -> void:
	if not states.has(state_name):
		push_warning("State '%s' does not exist on %s." % [state_name, name])
		return
	
	if current_state:
		current_state.exit()
	
	current_state = states[state_name]
	current_state.enter()


func _on_state_transition_requested(state_name: String) -> void:
	transition_to(state_name)
