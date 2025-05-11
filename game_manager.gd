extends Node

@export var has_game_started: bool = false
signal game_over

func restart_game() -> void:
	get_tree().reload_current_scene()
	
func end_game() -> void:
	game_over.emit()
	has_game_started = false

func start_game() -> void:
	has_game_started = true
