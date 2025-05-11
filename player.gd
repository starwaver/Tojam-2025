extends CharacterBody2D

@export var move_speed: float = 200.0
@export var swing_speed: float = 0.1
@export var swing_cd:    float = 0.20           # optional cool-down (s)
@export var player_color: Color = Color(1, 1, 1, 1)
@export var player_number: int = 1

@onready var player_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hand_sprite: Sprite2D = $Hand/Sprite2D
@onready var Sword: Node2D = $Hand/Sword

# --- sword swing control ---
var can_swing: bool = true
var progress := 0.0
var animation_length
var is_dead = false

# --- player controls
var move_left_key = "p1_move_left"
var move_right_key = "p1_move_right"
var swing_key = "p1_swing"

# --- health (for later combat testing) ---
var dir = 1.0
var previous_dir = 1.0
var health: int = 100

@onready var hand: Node2D = $Hand
@onready var animationPlayer  : AnimationPlayer = $AnimationPlayer

func _physics_process(delta):
	if !GameManager.has_game_started:
		return
	
	var input_vector = Vector2.ZERO
	
	if Input.is_action_pressed(move_left_key):
		input_vector.x -= 1
		dir = -1.0
	if Input.is_action_pressed(move_right_key):
		input_vector.x += 1
		dir = 1.0

	input_vector = input_vector.normalized()

	if previous_dir != dir:
		scale.x = -1
		previous_dir = dir

	if input_vector != Vector2.ZERO:
		velocity = input_vector * move_speed
		move_and_collide(velocity * delta)
	else:
		velocity = Vector2.ZERO

func _process(delta):
	# 1) Move progress toward 1 while held, toward 0 when released
	if Input.is_action_pressed(swing_key):
		progress = clamp(progress + delta * swing_speed, 0, 1)
	else:
		progress = clamp(progress - delta * swing_speed, 0, 1)

	# 2) Compute target time and scrub there
	animationPlayer.seek(progress, true)
		
func _ready() -> void:
	_set_player_color(player_color)
	if player_number == 2:
		move_left_key = "p2_move_left"
		move_right_key = "p2_move_right"
		swing_key = "p2_swing"
	
func _set_player_color(new_color: Color) -> void:
	player_color = new_color
	player_sprite.modulate = player_color
	hand_sprite.modulate = player_color

func take_damage(amount: int) -> void:
	if is_dead:
		return
		
	if health <= 0:
		player_sprite.play("R18G death")
		is_dead = true
		hand.hide()
		GameManager.end_game()
		return
		
	health -= amount
	player_sprite.play("Hit")

func _on_animated_sprite_2d_animation_finished() -> void:
	if player_sprite.animation == "Hit":
		player_sprite.play("Idle")
