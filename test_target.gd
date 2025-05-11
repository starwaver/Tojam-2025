extends Node2D

var health = 100

func take_damage(amount: int) -> void:
	health -= amount
	print("Hit for ", amount, " damage. Current health: ", health)
	if health <= 0:
		queue_free()
