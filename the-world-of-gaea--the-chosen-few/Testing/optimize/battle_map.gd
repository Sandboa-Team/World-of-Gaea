extends TileMapLayer
class_name BattleMap

@onready var camera_2d: Camera2D = $"../Camera2D"
@onready var occupied_space: Node = $"../OccupiedSpace"
#@export_enum("opt1", "opt2") var test = "opt1"
var selected_character = null
var finished_moving = true
var removed_navigation = {} #tiles that were removed but we want to keep the data

signal request_move

# _use_tile_data_runtime_update()
# _tile_data_runtime_update()
func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	##false means player can move on it
	##true means we have to remove tile
	for space in occupied_space.get_children():
		if coords == get_tile_vector(space.position):
			if selected_character and selected_character.name == space.name:
				return false
			return true
	return false
	


#the negate action
func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	##save removed tile info before its negate
	removed_navigation[coords] = tile_data.get_navigation_polygon(0)
	##the negate
	tile_data.set_navigation_polygon(0, null)
	pass

func _input(event: InputEvent) -> void:
	#when click
	if event is InputEventMouseButton:	
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if selected_character and selected_character.velocity == Vector2.ZERO:
				var mouse_position = camera_2d.get_global_mouse_position()
				var selected_tile = get_tile_vector(mouse_position)
				print("moving!")
				finished_moving = false
				request_move.emit(selected_character, get_global_vector(selected_tile))
			else:
				print("move denied")
# convert tile vector to global vector
#converts tile coordinates to global mouse position
func get_global_vector(vector):
	return to_global(map_to_local(vector))

#converts global mouse position to tile coordinates
func get_tile_vector(vector):
	return local_to_map(to_local(vector))	

func _on_playable_character_clicked_character(player) -> void:
	if not finished_moving:
		return
	selected_character = player

	#lets you switch to a different player
	if player:
		var player_coords = get_tile_vector(player.position)
		var cell_data = get_cell_tile_data(player_coords)
		var polygon = removed_navigation[player_coords]
		cell_data.set_navigation_polygon(0, polygon)
	print(player.name if player else "no player", " has been selected")

func _on_selected_character_finished_moving(character) -> void:
	selected_character = null
	finished_moving = true
	var player_coords = get_tile_vector(character.position)
	var cell_data = get_cell_tile_data(get_tile_vector(player_coords))
	#var polygon = removed_navigation[player_coords]
	#cell_data.set_navigation_polygon(0, polygon)
	
	cell_data.set_navigation_polygon(0, null)
	pass
	
func connect_clicked_character(character_signal: Signal):
	character_signal.connect(_on_playable_character_clicked_character)
	
func connect_finished_moving(character_signal: Signal):
	character_signal.connect(_on_selected_character_finished_moving)
