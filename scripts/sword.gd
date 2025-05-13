class_name Sword
extends Node2D

@export var speed_damage_ratio: float = 0.005
@export var player: Player

var _prev_global_pos: Vector2
var _current_speed: float = 0.0

var _min_damage: int = 3
var _max_damage: int = 10
var _damage: int = _min_damage

@onready var hitbox: Hitbox = $Hitbox

func _ready() -> void:
	_prev_global_pos = global_position
	player.stats_changed.connect(_on_player_stat_changed)

func _physics_process(delta: float) -> void:
	var displacement = global_position - _prev_global_pos
	_current_speed = displacement.y / delta
	_prev_global_pos = global_position
	hitbox.damage = _calculate_damage()
	
func _on_player_stat_changed():
	scale.x = player.sword_length
	_min_damage = player.min_damage
	_max_damage = player.max_damage
	if (player.is_goat):
		_change_to_goat()
	
func _change_to_goat():
	get_node("Goat").show()
	get_node("Sprite2D").hide()	
	
func _calculate_damage() -> int:
	_damage = clamp(_current_speed * speed_damage_ratio, _min_damage, _max_damage)
	
	if player.swing_progress < 0.1 or player.swing_progress > 0.9:
		hitbox.monitorable = false
	else:
		hitbox.monitorable = true
	return _damage
