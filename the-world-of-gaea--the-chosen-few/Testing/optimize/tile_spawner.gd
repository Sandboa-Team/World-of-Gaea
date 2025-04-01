extends Area2D

@export var map: BattleMap

func _ready() -> void:
	position = map.get_global_vector(map.get_tile_vector(position))
