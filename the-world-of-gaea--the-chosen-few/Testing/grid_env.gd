extends Node2D

@onready var tile_map: TileMapLayer = $TileMap
@onready var players: Node = $Players
@onready var camera_2d: Camera2D = $Camera2D

func _ready() -> void:
	camera_2d.make_current()
	
	#adds player nodes to occupied space
	for player in players.get_children():
		print(player)
		tile_map.update_tilemap(player)
	pass
	
