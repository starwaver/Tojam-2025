extends Control

func _ready() -> void:
	get_node("StartScreen").show()
	get_node("EndScreen").hide()

func start_the_game() -> void:
	GameManager.has_game_started = true
	get_node("StartScreen").hide()
	
func game_end() -> void:
	get_node("EndScreen").show()
