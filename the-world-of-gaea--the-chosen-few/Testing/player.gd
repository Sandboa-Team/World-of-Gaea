extends CharacterBody2D

var speed = 50.0
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
var target = null

signal player_selected
signal moved_spots


func _ready() -> void:
	print(navigation_agent_2d.target_desired_distance)
	print(position, " initial pos")

#sets target to destination
func seeker_setup(target):
	#probably waits for physics process to update
	await get_tree().physics_frame
	
	#sets the navigation
	if target:
		navigation_agent_2d.target_position = target

func _physics_process(delta: float) -> void:
	
	#when sub step (the red squares) is done, return
	if navigation_agent_2d.is_navigation_finished():
		return
		
	#if navigation is impossible, negate and reset
	if not navigation_agent_2d.is_target_reachable():
		navigation_agent_2d.target_position = position
		velocity = Vector2.ZERO
		moved_spots.emit(self)
		player_selected.emit(null)
		return
	
	#makes player move to the next substep (red squares)
	var current_agent_position = global_position
	var next_path_position = navigation_agent_2d.get_next_path_position()
	
	#if the player is close enough, snap to grid, negate path and reset
	#player has finised moving
	if current_agent_position.distance_to(target) < navigation_agent_2d.target_desired_distance+1:
		print("close enough", target, name)
		#position = navigation_agent_2d.get_next_path_position()
		position = target
		velocity = Vector2.ZERO
		#signal emit that player has finished moving
		moved_spots.emit(self)
		#signal emit to reset the selected player to null
		player_selected.emit(null)
	else:
		#make the player avoid objects
		var new_v =  current_agent_position.direction_to(next_path_position) * speed
		if navigation_agent_2d.avoidance_enabled:
			navigation_agent_2d.set_velocity(new_v)
		else:
			_on_navigation_agent_2d_velocity_computed(new_v)
			
	move_and_slide()

#if this player was the one select, set the target as destination to move
func _on_tile_map_request_move(selected_name, coord) -> void:
	if selected_name != name:
		return
	target = coord
	#probably, waits for code to be ready before it can work
	call_deferred("seeker_setup", coord)

#detect when mouse clicks on player
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		player_selected.emit(self)

# used to make player avoid objects
func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
