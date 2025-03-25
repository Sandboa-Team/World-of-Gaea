extends TileMapLayer

#@onready var player: CharacterBody2D = $"../Players/Player"
@onready var grid_env: Node2D = $".."
@onready var camera_2d: Camera2D = $"../Camera2D"
@onready var players: Node = $"../Players"
var requested_position = Vector2i(0,0)
var selected_player = null
var tile_space = {} #tiles that are currently occupied
var removed_navigation = {} #tiles that were removed but we want to keep the data

var finished_moving = true

signal request_move

#filters navigatable tiles
#also filters anything on tile
#shows where player can move
func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	#false means player can move on it
	#true means we have to remove tile
	for node in tile_space:
		#if the tile is occupied, negate...
		if coords == tile_space[node]:
			#... EXCEPT if you select the player, the spot they stands on is valid
			if selected_player and selected_player.name == node:
				return false
			return true
	return false

#the negate action
func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	#save removed tile info before its negate
	removed_navigation[coords] = tile_data.get_navigation_polygon(0)
	#the negate
	tile_data.set_navigation_polygon(0, null)
	
func _ready() -> void:
	#centers players on tile
	if players:
		for player in players.get_children():
			requested_position = getTileVector(player.position)
			request_move.emit(player.name, to_global(map_to_local(requested_position)))

func _input(event: InputEvent) -> void:
	#when click
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var global_mouse_position = camera_2d.get_global_mouse_position()
			var pos_clicked = getTileVector(global_mouse_position)
			
			#if click on a spot with 0 blue tiles, negate
			if not is_valid_grid(pos_clicked):
				return
			
#			#if a player is selected and they are not moving, they can move
			if selected_player and selected_player.velocity == Vector2.ZERO:
				#useful for _on_player_selected()
				finished_moving = false
				print("moving!")
				requested_position = pos_clicked
				
				#requests select player to move (signal emit)
				request_move.emit(selected_player.name, to_global(map_to_local(pos_clicked)))
			else:
				print("move denied")

#updates occupied tile
func update_tilemap(node):
	tile_space[node.name] = getTileVector(node.position)

#converts global mouse position to tile coordinates
func getTileVector(vector):
	return local_to_map(to_local(vector))	
	
func is_valid_grid(tile_vector):
	var data = get_cell_tile_data(tile_vector)
	for node in tile_space:
		if tile_space[node] == tile_vector:
			return false
	#If this is a navigatable spot
	if data and data.get_navigation_polygon(0) != null:
		return true
	else:
		return false

func _on_player_selected(player) -> void:
	#if theres a player currently moving, you cant select a different player
	if not finished_moving:
		return
	selected_player = player
	
	#lets you switch to a different player
	if player:
		var player_coords = tile_space[player.name]
		var cell_data = get_cell_tile_data(player_coords)
		var polygon = removed_navigation[player_coords]
		cell_data.set_navigation_polygon(0, polygon)
	print(player.name if player else "no player", " has been selected")

#player move to new spot
func _on_player_moved_spots(player) -> void:
	#negates new spot
	var player_coords = tile_space[player.name]
	var cell_data = get_cell_tile_data(player_coords)
	var polygon = removed_navigation[player_coords]
	cell_data.set_navigation_polygon(0, polygon)
	
	#you can select a different player now
	finished_moving = true

	update_tilemap(player)
