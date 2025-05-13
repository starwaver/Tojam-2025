class_name Player
extends CharacterBody2D

# --- CONFIGURATION (EXPORTS) ---
@export var player_number: int = 1
@export var player_color: Color = Color(1, 1, 1, 1)
@export var is_goat: bool = false

@export var move_speed: float = 200.0

@export var swing_speed: float = 0.5
@export var swing_cooldown: float = 0.20
@export var sword_length: float = 3.0
@export var min_damage: int = 3
@export var max_damage: int = 10

@export var max_health: int = 100

# --- STATE VARIABLES ---
var current_health: int
var is_dead: bool = false

var can_swing: bool = true
var is_swinging: bool = false
var swing_progress: float = 0.0
var animation_length: float = 0.0

var facing_direction: float = 1.0
var previous_facing_direction: float = 1.0

# --- INPUT ACTION NAMES ---
var action_move_left: String
var action_move_right: String
var action_swing: String

# --- SIGNALS ---
signal health_changed
signal stats_changed

# --- NODE REFERENCES ---
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hand_node: Node2D          = $Hand
@onready var hand_sprite: Sprite2D      = hand_node.get_node("Sprite2D")
@onready var sword_node: Node2D         = hand_node.get_node("Sword")
@onready var swing_timer: Timer         = $SwingTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# --- GODOT CALLBACKS ---
func _ready() -> void:
	# initialize health
	current_health = max_health

	# apply initial color
	_apply_player_color(player_color)

	# dynamic input mapping
	action_move_left  = "p%s_move_left" % player_number
	action_move_right = "p%s_move_right" % player_number
	action_swing      = "p%s_swing"      % player_number

	# timer setup
	swing_timer.wait_time = swing_cooldown
	swing_timer.timeout.connect(_on_swing_timer_timeout)

	# animation_finished hookup
	animated_sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	if not GameManager.has_game_started:
		return

	var input_vector = Vector2.ZERO

	if Input.is_action_pressed(action_move_left):
		input_vector.x = -1
	elif Input.is_action_pressed(action_move_right):
		input_vector.x = 1

	# update facing
	if input_vector.x != 0:
		facing_direction = input_vector.x
	if facing_direction != previous_facing_direction:
		scale.x = facing_direction
		previous_facing_direction = facing_direction

	# movement
	velocity = input_vector.normalized() * move_speed
	if velocity != Vector2.ZERO:
		move_and_collide(velocity * delta)
	else:
		velocity = Vector2.ZERO

func _process(delta: float) -> void:
	# handle swing progress
	if Input.is_action_pressed(action_swing) and can_swing:
		is_swinging = true
	else:
		is_swinging = false

	# update progress (0 → 1 on press, back on release)
	var delta_progress = delta * swing_speed
	
	if is_swinging:
		swing_progress = clamp(swing_progress + delta_progress, 0, 1)
	else:
		swing_progress = clamp(swing_progress - delta_progress, 0, 1)

	# once user releases mid-swing, start cooldown
	if swing_progress > 0.0 and !Input.is_action_pressed(action_swing):
		can_swing = false
		swing_timer.start()
 
	# scrub animation
	animation_player.seek(swing_progress, true)

# --- GAMEPLAY LOGIC ---
func apply_damage(amount: int) -> void:
	if is_dead:
		return

	current_health -= amount
	emit_signal("health_changed")

	if current_health <= 0:
		_die()
	else:
		animated_sprite.play("Hit")
		$AudioStreamPlayer2D.play()

func _die() -> void:
	is_dead = true
	animated_sprite.play("R18G_death")
	hand_node.hide()
	GameManager.end_game()

func apply_power_up(
		speed_increase: float = 0.0,
		length_multiplier: float = 1.0,
		damage_increase: int = 0
	) -> void:
	if speed_increase != 0.0:
		move_speed += speed_increase
	if length_multiplier != 0.0:
		sword_length    = clamp(length_multiplier * sword_length, 1, 10)
		swing_speed     = clamp(swing_speed / length_multiplier, 1, 10.0)
		swing_cooldown  = clamp(swing_cooldown * length_multiplier * 0.2, 0.2, 2)
	if damage_increase != 0:
		min_damage = clamp(max_damage + damage_increase, 1, 20)
		max_damage = clamp(max_damage + damage_increase, 1, 20)

	emit_signal("stats_changed")

func transform_to_goat() -> void:
	is_goat = true
	emit_signal("stats_changed")

# --- SIGNAL CALLBACKS ---
func _on_animation_finished() -> void:
	if animated_sprite.animation == "Hit":
		animated_sprite.play("Idle")

func _on_swing_timer_timeout() -> void:
	can_swing = true

# --- HELPERS ---
func _apply_player_color(new_color: Color) -> void:
	player_color = new_color
	animated_sprite.modulate = new_color
	hand_sprite.modulate     = new_color
