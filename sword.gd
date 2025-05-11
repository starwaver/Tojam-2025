class_name Sword
extends Node2D

@export var speedDamageRatio: float = 0.005
@export var player: Player

var _prev_global_pos: Vector2
var _current_speed: float = 0.0

var _minDamage: int = 3
var _maxDamage: int = 10
var _damage: int = _minDamage

@onready var hitbox: Hitbox = $Hitbox

func _ready() -> void:
	_prev_global_pos = global_position
	player.statChanged.connect(_on_player_stat_changed)

func _physics_process(delta: float) -> void:
	var displacement = global_position - _prev_global_pos
	_current_speed = displacement.length() / delta
	_prev_global_pos = global_position
	hitbox.damage = _calculate_damage()
	
func _on_player_stat_changed():
	scale.x = player.swordLength
	_minDamage = player.minDamage
	_maxDamage = player.maxDamage
	if (player.isGoat):
		_change_to_goat()
	
	
func _change_to_goat():
	get_node("Goat").show()
	get_node("Sprite2D").hide()
	
func _calculate_damage() -> int:
	_damage = clamp(_current_speed * speedDamageRatio, _minDamage, _maxDamage)
	return _damage
