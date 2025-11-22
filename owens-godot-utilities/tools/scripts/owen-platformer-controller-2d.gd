class_name OwenPlatformerController2D
extends CharacterBody2D

# OwenPlatformerController2D
# A simple platformer character controller for 2D games.
# version 1.1.0
# last updated: 2025-11-21

@export_group("Movement")

## Your maximum horizontal speed.
@export var speed: float = 300.0

## The gravity rate affects how quickly the character falls in cm/s. In real life, this is 980 cm/s
@export var gravity_rate: float = 980

## The amount sprint will increase your horizontal movement speed.
@export var sprint_multiplier: float = 1.5

@export_subgroup("Acceleration")
## How quickly a character reaches their max speed on the ground.
@export var acceleration: float = 25.0
## How quickly a character reaches their max speed in the air.
@export var acceleration_air: float = 10.0

@export_subgroup("Friction")
## How quickly a character stops when input is not given.
@export var friction: float = 25.0
## How quickly a character stops in the air when input is not given.
@export var friction_air: float = 10.0

@export_subgroup("Jumping")
## This is the initial upwards velocity of a jump.
@export var jump_velocity: float = -400.0
## Coyote time allows you to jump shortly after leaving a ledge to make it feel less punishing.
## When you leave the ground, you have this many seconds to still perform a jump.
@export var coyote_time: float = 0.1
# This timer tracks how long is left in the coyote time window.
var coyote_timer: float = 0.0
# This timer tracks how long is left in the wall coyote time window.
var wall_coyote_timer: float = 0.0

## Allows jump inputs to be buffered and used before you actually hit the ground.
## When pressing jump in air, you have this many seconds where the jump is considered valid.
@export var max_jump_buffer_time: float = 0.1
# This timer tracks how long is left in the jump buffer window.
var jump_buffer_timer: float = 0.0

## How much you'll be slowed by sliding down a wall.
@export var wall_slide_slow_rate: float = 0.25
## This is the horizontal velocity of a wall jump.
@export var wall_jump_velocity: float = 400.0
## The time after a wall jump during which normal horizontal control is disabled.
@export var max_wall_jump_time: float = 0.2
# This timer tracks how long is left in the wall jump control disable window.
var wall_jump_timer = 0

## A multiplier to apply to horizontal movement during a jump.
@export var horizontal_jump_multiplier: float = 1.0
var current_horizontal_jump_multiplier: float = horizontal_jump_multiplier

## The amount to reduce upwards velocity when the jump button is released early.
@export var jump_cutoff_multiplier: float = 0.5

# Animation Variables
@export_group("Animation")

# The animation player to use for playing animations on the player, if desired.
@onready var anim_player: AnimationPlayer = $AnimationPlayer
# The sprite to flip based on movement direction, if desired.
@onready var sprite: Sprite2D = $CollisionShape2D/Sprite2D

@export_subgroup("Animation Strings")
## The string name to pass to the animation player for the idle animation.
@export var IdleAnimString : String = "player_idle"
## The string name to pass to the animation player for the walk animation.
@export var WalkAnimString : String = "player_walk"
## The string name to pass to the animation player for the jump animation.
@export var JumpAnimString : String = "player_jump"

## Each enum is a possible discrete animation state for the character.
## Add more as needed.
enum ANIM_STATE {
	IDLE,
	WALK,
	JUMP
}
## The current animation state of the character.
var anim_state: ANIM_STATE = ANIM_STATE.IDLE

## Each enum is a possible discrete animation state for the character.
## Add more as needed.
enum CHARACTER_STATE {
	ACTIVE,
	RESPAWNING,
	TRANSITIONING
}
## The current state of the character.
var cur_state: CHARACTER_STATE = CHARACTER_STATE.ACTIVE

func _increment_timers(delta: float) -> void:
	# Increments all timers by delta time.
	coyote_timer = max(0, coyote_timer - delta)
	wall_coyote_timer = max(0, wall_coyote_timer - delta)
	jump_buffer_timer = max(0, jump_buffer_timer - delta)
	wall_jump_timer = max(0, wall_jump_timer - delta)

# Do all processing related to jumping here
func _proccess_jump() -> void:
	if Input.is_action_just_pressed("2d_platformer_jump"):
		jump_buffer_timer = max_jump_buffer_time
	elif Input.is_action_just_released("2d_platformer_jump"):
		if velocity.y < 0 and not is_on_floor():
			velocity.y *= jump_cutoff_multiplier

	# If we have pressed the jump button recently, and are allowed to jump, do so.
	if jump_buffer_timer > 0:
		if coyote_timer > 0:
			_jump()

		elif wall_coyote_timer > 0 and not is_on_floor():
			velocity.x = (get_wall_normal().x * wall_jump_velocity)
			wall_jump_timer = max_wall_jump_time
			_jump()

# Best to be used for processing things which should happen immediately every frame,
# such as input detection or jumping
func _process(delta: float) -> void:

	# Input Processing
	# If the character is respawning, freeze and skip all movement logic
	if cur_state == CHARACTER_STATE.RESPAWNING:
		velocity = Vector2.ZERO
		return

	# Update timers
	_increment_timers(delta)

	# Process jump logic
	_proccess_jump()
	pass

func _get_wall_slide_rate() -> float:
	return wall_slide_slow_rate if (is_on_wall() and velocity.y > 0) else 1.0

func _physics_process(delta: float) -> void:
	# If the character is respawning, freeze and skip all movement logic
	if cur_state == CHARACTER_STATE.RESPAWNING:
		velocity = Vector2.ZERO
		return

	# local variables for acceleration and friction
	var acc = acceleration
	var fric = friction

	# Reset coyote time when on the floor, otherwise apply gravity
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		velocity.y += gravity_rate * delta * _get_wall_slide_rate()
		acc = acceleration_air
		fric = friction_air
	
	if is_on_wall():
		wall_coyote_timer = coyote_time

	var input_axis = Input.get_axis("2d_platformer_move_left", "2d_platformer_move_right")
	
	# If we are not in the wall jump phase, allow normal horizontal control
	if wall_jump_timer <= 0:
		if input_axis != 0:
			velocity.x = lerp(velocity.x, 
			input_axis * speed * current_horizontal_jump_multiplier * _get_sprint_multiplier(), 
			acc * delta)
		else:
			velocity.x = lerp(velocity.x, 0.0, fric * delta)

	move_and_slide()

	# update the horizontal jump multiplier if necessary
	if current_horizontal_jump_multiplier != 1.0 and is_on_floor():
		current_horizontal_jump_multiplier = 1.0

# Jump logic, called when a jump is to be performed
func _jump():
	velocity.y = jump_velocity
	current_horizontal_jump_multiplier = horizontal_jump_multiplier
	velocity.x *= current_horizontal_jump_multiplier
	jump_buffer_timer = 0
	coyote_timer = 0
	wall_coyote_timer = 0

func _get_sprint_multiplier() -> float:
	if is_on_floor() and Input.is_action_pressed("2d_platformer_sprint"):
		return sprint_multiplier
	return 1.0

func hit():
	if cur_state == CHARACTER_STATE.ACTIVE:
		# Implement your hit logic here, such as reducing health or triggering animations
		pass

func set_state(state: CHARACTER_STATE) -> void:
	if cur_state == state:
		return

	# Reset any necessary variables for the new state
	match cur_state:
		CHARACTER_STATE.ACTIVE:
			# Reset the character for the active state
			pass
		CHARACTER_STATE.RESPAWNING:
			# Reset the character for the respawning state
			pass
		CHARACTER_STATE.TRANSITIONING:
			# Reset the character for the transitioning state
			pass

	# Set the new state, and update appropriate variables
	cur_state = state
	match state:
		CHARACTER_STATE.ACTIVE:
			# Set up the character for the active state
			pass
		CHARACTER_STATE.RESPAWNING:
			# Set up the character for the respawning state
			pass
		CHARACTER_STATE.TRANSITIONING:
			# Set up the character for the transitioning state
			pass
