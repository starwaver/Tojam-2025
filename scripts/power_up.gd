class_name PowerUp
extends Node2D

@export var speed_up_amount: float = 0.0
@export var sword_growth_amount: float = 0.0
@export var damage_up_amount: int = 0.0

@export var isGoat: bool = false

@onready var collision2D: Area2D = $RigidBody2D/Area2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("apply_power_up"):
		body.apply_power_up(speed_up_amount, sword_growth_amount, damage_up_amount)
		queue_free()
		
	if body.has_method("transform_to_goat") && isGoat:
		body.transform_to_goat()
		queue_free()
