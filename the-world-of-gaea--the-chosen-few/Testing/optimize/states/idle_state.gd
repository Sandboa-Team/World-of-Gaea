extends State

@export var character: CharacterBody2D
@export var sprite: AnimatedSprite2D

func Enter():
	sprite.play("idle")
	pass
	
func Exit():
	pass

func Update(_delta: float):
	pass
	
func Physics_Update(_delta: float):
	pass
	
