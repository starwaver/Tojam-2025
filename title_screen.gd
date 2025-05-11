extends Control

@onready var KO_sprite: AnimatedSprite2D = $EndScreen/AnimatedSprite2D

func _ready() -> void:
	get_node("StartScreen").show()
	get_node("EndScreen").hide()
	GameManager.game_over.connect(game_end)

func start_the_game() -> void:
	GameManager.start_game()
	get_node("StartScreen").hide()
	
func game_end() -> void:
	get_node("EndScreen").show()
	KO_sprite.play()

func restart_game():
	GameManager.restart_game()
