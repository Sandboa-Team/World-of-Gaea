extends Node2D

@export var stats_resource : BattlerStats

@onready var health_bar: ProgressBar = $HealthBar

@onready var turn_indicator_animation: AnimationPlayer = $TurnIndicator/TurnIndicatorAnimation
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hit_fx_animation: AnimationPlayer = $HitFX/HitFXAnimation

var current_hp : int

signal dead(this_battler: Node2D)
signal turn_ended


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stop_turn()
	
	current_hp = stats_resource.max_HP
	
	_update_health_bar()
	
func _update_health_bar() -> void:
	health_bar.max_value = stats_resource.max_HP
	health_bar.value = current_hp
	
func start_turn() -> void:
	#turn_indicator_animation.play("in_turn")
	pass
	
func stop_turn() -> void:
	#turn_indicator_animation.play("RESET")
	#animation_player.play("RESET")
	#hit_fx_animation.play("RESET")
	pass
	
func start_attacking(enemy_target: Node2D) -> void:
	_play_attack_anim()
	await get_tree().create_timer(0.6).timeout
	enemy_target.play_hit_fx_anim()
	await get_tree().create_timer(0.5).timeout
	enemy_target.be_damaged(_get_attack_damage())
	await get_tree().create_timer(0.1).timeout
	turn_ended.emit()
	
func _play_attack_anim() -> void:
	#animation_player.play("attack")
	pass
	
func _get_attack_damage() -> int:
	return randi_range(stats_resource.min_Damage, stats_resource.max_Damage)
	
func play_hit_fx_anim() -> void:
	#hit_fx_animation.play("play")
	pass
	
func be_damaged(amount: int) -> void:
	current_hp -= amount
	_update_health_bar()
	if current_hp <= 0:
		current_hp = 0
		dead.emit(self)
		queue_free()
