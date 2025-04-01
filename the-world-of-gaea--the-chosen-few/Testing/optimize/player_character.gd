extends CharacterBody2D

@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: StateMachine = $StateMachine
@onready var idle_state: Node = $StateMachine/Idle
@onready var navigate_state: Node = $StateMachine/Navigate
@export_enum("default", "battle") var Game_Mode = "default"

const SPEED = 50.0
var target = null

signal clicked_character
signal finished_moving

func _physics_process(delta: float) -> void:
	if velocity.x < 0:
		animated_sprite_2d.flip_h = false
		animated_sprite_2d.play("walk_side")
	elif velocity.x > 0:
		animated_sprite_2d.flip_h = true
		animated_sprite_2d.play("walk_side")
	elif velocity.y > 0:
		animated_sprite_2d.play("walk_down")
	elif velocity.y < 0:
		animated_sprite_2d.play("walk_up")

func move(global_vector):
	if Game_Mode != "battle":
		return
	if state_machine.current_state.name.to_lower() != "navigate":
		navigate_state.target = global_vector
	state_machine._on_child_transition(idle_state, "navigate")

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		clicked_character.emit(self)

func _on_navigate_finished_moving() -> void:
	finished_moving.emit(self)
