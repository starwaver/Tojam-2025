extends Node2D

@export var minDamage: int = 3
@export var maxDamage: int = 10
@export var speedDamageRatio: float = 0.005

var _prev_global_pos: Vector2
var _current_speed: float = 0.0

@onready var hitbox: Hitbox = $Hitbox

func _ready() -> void:
	_prev_global_pos = global_position

func _physics_process(delta: float) -> void:
	var displacement = global_position - _prev_global_pos
	_current_speed = displacement.length() / delta
	_prev_global_pos = global_position
	hitbox.damage = _calculate_damage()
	
func _calculate_damage() -> int:
	var damage = clamp(_current_speed * speedDamageRatio, minDamage, maxDamage)
	return damage
