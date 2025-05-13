class_name Hurtbox
extends Area2D

func _init() -> void:
	collision_layer = 0
	collision_mask = 2

func _ready() -> void:
	connect("area_entered", self._on_area_entered)
	
func _on_area_entered(hitbox: Hitbox) -> void:
	if hitbox == null:
		return
		
	if owner.has_method("apply_damage"):
		owner.apply_damage(hitbox.damage)
