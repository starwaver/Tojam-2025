extends Node

@export var has_game_started: bool = false
@export var end_screen: Control
signal game_over
signal game_started

func restart_game() -> void:
	get_tree().reload_current_scene()
	
func end_game() -> void:
	has_game_started = false
	game_over.emit()

func start_game() -> void:
	has_game_started = true
	game_started.emit()
