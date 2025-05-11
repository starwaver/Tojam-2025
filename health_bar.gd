extends TextureProgressBar

@export var player: Player

func update_health():
	value = player.currentHealth * 100 / player.maxHealth
	
func _ready() -> void:
	player.healthChanged.connect(update_health)
	update_health()
