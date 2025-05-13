extends TextureProgressBar

@export var player: Player

func update_health():
	value = player.current_health * 100 / player.max_health
	
func _ready() -> void:
	player.health_changed.connect(update_health)
	update_health()
