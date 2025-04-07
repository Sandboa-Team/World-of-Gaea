extends Node2D
@onready var camera_2d: Camera2D = $Camera2D
@onready var map: BattleMap = $BattleMap
@onready var player_spawners: Node = $PlayerSpawners
@onready var occupied_space: Node = $OccupiedSpace

###this will become a global variable
var party_roster = [
	{"name": "", "battle_position": "frontline"},
	{"name": "", "battle_position": "frontline"},
	{"name": "", "battle_position": "backline"},
	{"name": "", "battle_position": "frontline"},
	]
var battle_positions_occupied = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera_2d.make_current()
	spawn_characters()
	
func spawn_characters():
	for character in party_roster:
		var character_instant = load("res://Testing/optimize/PlayerCharacter.tscn").instantiate()
		character_instant.position = assign_battle_position(character.battle_position)
		character_instant.Game_Mode = "battle"
		map.connect_clicked_character(character_instant.clicked_character)
		map.connect_finished_moving(character_instant.finished_moving)
		occupied_space.add_child(character_instant)

func assign_battle_position(battle_position):
	for spawner in player_spawners.get_children():
		if spawner.name.to_lower().begins_with(battle_position):
			if not battle_positions_occupied.has(spawner.name):
				battle_positions_occupied[spawner.name] = spawner.position
				return spawner.position
	
func _on_request_move(character, move) -> void:
	character.move(move)
