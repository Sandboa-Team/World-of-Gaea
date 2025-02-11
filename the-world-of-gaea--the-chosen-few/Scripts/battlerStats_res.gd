extends Resource
class_name BattlerStats

enum BattlerType{
	PLAYER,
	ENEMY
}

@export var type : BattlerType
@export var max_HP : int
@export var min_Damage : int
@export var max_Damage : int
@export var turn_Speed : int # Use to determine turn order
