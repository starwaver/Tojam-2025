extends Node2D

# @export var spawnableObject = preload ("res://power_up.tscn") 
@export var spawnableObjects:Array[PackedScene]

@onready var spawnTimer: Timer = $SpawnTimer
var screen_width

func _ready():
	screen_width = get_viewport_rect().size.x / 2
	GameManager.game_started.connect(start_timer)

func spawn():
	var random_index = randi() % spawnableObjects.size()
	var obj = spawnableObjects[random_index]
	var powerup = obj.instantiate()
	add_child(powerup)
	var x_pos = randf_range(-screen_width, screen_width)
	powerup.position = Vector2(x_pos, self.position.y)

func _on_spawn_timer_timeout() -> void:
	spawn()

func start_timer() -> void:
	spawnTimer.start()
