@tool
extends Node
class_name StateMachine

@export var initial_State: State
var states: Dictionary = {}
var current_state: State

func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.Transition.connect(_on_child_transition)
			
	if initial_State:
		initial_State.Enter()
		current_state = initial_State

func _process(delta: float) -> void:
	if current_state:
		current_state.Update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.Physics_Update(delta)
		

func _on_child_transition(state, new_state_name):
	if state != current_state:
		return
		
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
		
	if current_state:
		current_state.Exit()
	new_state.Enter()
	current_state = new_state
