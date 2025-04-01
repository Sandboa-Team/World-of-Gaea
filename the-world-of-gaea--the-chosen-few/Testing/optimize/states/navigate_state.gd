extends State

@export var character: CharacterBody2D
@export var navigation_agent_2d: NavigationAgent2D

const SPEED = 50.0
var target = null

signal finished_moving

func Enter():
	if target:
		move(target)

func move(global_vector):
	target = global_vector
	call_deferred("navigation_setup", target)

#sets target to destination
func navigation_setup(target):
	#probably waits for physics process to update
	await get_tree().physics_frame
	#sets the navigation
	if target:
		navigation_agent_2d.target_position = target

func Physics_Update(_delta: float):
	pass
	if not target:
		return
	if not navigation_agent_2d.is_target_reachable():
		complete_navigation()
		return
	
	var current_agent_position = character.global_position
	var next_path_position = navigation_agent_2d.get_next_path_position()	
	
	if current_agent_position.distance_to(target) < navigation_agent_2d.target_desired_distance+1:
		character.position = target
		complete_navigation()
	else:
		var new_v = current_agent_position.direction_to(next_path_position) * SPEED
		character.velocity = new_v
	character.move_and_slide()
	
func complete_navigation():
	character.velocity = Vector2.ZERO
	target = null
	navigation_agent_2d.target_position = character.position
	navigation_agent_2d.get_next_path_position()
	Transition.emit(self, "idle")
	finished_moving.emit()
