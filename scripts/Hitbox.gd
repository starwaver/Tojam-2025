class_name Hitbox
extends Area2D

@export var damage: int = 25           # per hit

@onready var hitbox: CollisionShape2D = $CollisionShape2D

func _init() -> void:
	collision_layer = 2
	collision_mask = 0
