class_name Player
extends CharacterBody2D

@export var player_number: int = 1

@export var move_speed: float = 200.0
@export var swing_speed: float = 0.5
@export var swing_cd:    float = 0.20
@export var player_color: Color = Color(1, 1, 1, 1)
@export var maxHealth: int = 100
@export var swordLength: float = 3.0
@export var minDamage: int = 3
@export var maxDamage: int = 10
@export var isGoat: bool = false

@onready var player_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hand_sprite: Sprite2D = $Hand/Sprite2D
@onready var playerSword: Node2D = $Hand/Sword
@onready var SwingTimer: Timer = $SwingTimer

# --- sword swing control ---
var can_swing: bool = true
var progress := 0.0
var animation_length
var is_dead = false
var is_swinging: bool = false

# --- player controls
var move_left_key = "p1_move_left"
var move_right_key = "p1_move_right"
var swing_key = "p1_swing"

# --- health (for later combat testing) ---
var dir = 1.0
var previous_dir = 1.0

var currentHealth: int = maxHealth

signal healthChanged
signal statChanged

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
	
	if is_swinging:
		progress = clamp(progress + delta * swing_speed, 0, 1)
	else:
		progress = clamp(progress - delta * swing_speed, 0, 1)
	
	if Input.is_action_pressed(swing_key) && can_swing:
		is_swinging = true
	else:
		is_swinging = false
	
	if progress > 0 && !Input.is_action_pressed(swing_key):
		can_swing = false
		SwingTimer.start()

	# 2) Compute target time and scrub there
	animationPlayer.seek(progress, true)
		
func _ready() -> void:
	_set_player_color(player_color)
	SwingTimer.wait_time = (swing_cd)
	statChanged.emit()
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
	
	if currentHealth <= 0:
		player_sprite.play("R18G death")
		is_dead = true
		hand.hide()
		GameManager.end_game()
		return
		
	currentHealth -= amount
	player_sprite.play("Hit")
	$AudioStreamPlayer2D.play()
	healthChanged.emit()

func _on_animated_sprite_2d_animation_finished() -> void:
	if player_sprite.animation == "Hit":
		player_sprite.play("Idle")

func _on_swing_timer_timeout() -> void:
	can_swing = true

func power_up(speed_up_amount, sword_growth_amount, damage_up_amount):
	if (speed_up_amount != 0):
		move_speed += speed_up_amount
	
	if (sword_growth_amount != 0):
		swordLength	*= sword_growth_amount
		swing_speed /= sword_growth_amount * 1.5
		swing_cd *= sword_growth_amount * 0.2
	
	if (damage_up_amount != 0):
		minDamage += damage_up_amount
		maxDamage += damage_up_amount
	
	statChanged.emit()
	
func Goat():
	isGoat = true
	statChanged.emit()
