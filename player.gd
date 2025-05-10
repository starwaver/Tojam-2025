extends CharacterBody2D

# --- movement constants ---
const SPEED := 200.0

@export var arc_up:      float = -45.0          # degrees – “rest” angle
@export var arc_down:    float =  45.0          # degrees – lowest point
@export var swing_speed: float = 540.0          # degrees per second
@export var swing_cd:    float = 0.20           # optional cool-down (s)

# --- sword swing control ---
var can_swing: bool = true
const SWING_COOLDOWN := 0.30          # seconds

# --- health (for later combat testing) ---
var dir = 1.0
var previous_dir = 1.0
var health: int = 100

@onready var hand: Node2D = $Hand
@onready var tree  : AnimationTree = $AnimationTree
@onready var state : AnimationNodeStateMachinePlayback = tree.get("parameters/playback")


func _physics_process(delta):
	var input_vector = Vector2.ZERO
	
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
		dir = -1.0
		
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1
		dir = 1.0

	input_vector = input_vector.normalized()

	if previous_dir != dir:
		scale.x = -1
		previous_dir = dir

	if input_vector != Vector2.ZERO:
		velocity = input_vector * SPEED
		move_and_collide(velocity * delta)
	else:
		velocity = Vector2.ZERO
		
func _ready() -> void:
	reset_sword()
	
func reset_sword() -> void:
	hand.rotation_degrees = arc_up
	
func update_sword(delta: float) -> void:
	var wants := Input.is_action_pressed("swing") and can_swing
	var target := arc_down if wants else arc_up

	# rotate toward target at swing_speed degrees / second
	hand.rotation_degrees = move_toward(
		hand.rotation_degrees,
		target,
		swing_speed * delta
	)
	
		# 3. Hit-box & visibility housekeeping
	# if wants:
		# hand.hitbox.disabled = false
	# else:
		# once the blade is all the way back up we can hide/disable it
		# if absf(hand.rotation_degrees - arc_up) < 0.1:
			# sword.hitbox.disabled = true

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		queue_free()
