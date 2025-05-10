extends Area2D

@export var damage:      int   = 25           # per hit

@onready var hitbox: CollisionShape2D = $CollisionShape2D

func _on_body_entered(body: Node) -> void:
	if !hitbox.disabled and body.has_method("take_damage"):
		body.take_damage(damage)
