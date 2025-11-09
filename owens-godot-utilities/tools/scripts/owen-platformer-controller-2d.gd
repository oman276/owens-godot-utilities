class_name OwenPlatformerController2D
extends CharacterBody2D

# OwenPlatformerController2D
# A simple platformer character controller for 2D games.
# version 1.0.0
# last updated: 2025-10-19

@export_group("Movement")

## Your maximum horizontal speed.
@export var speed: float = 300.0

## The gravity rate affects how quickly the character falls in cm/s. In real life, this is 980 cm/s
@export var gravity_rate: float = 980

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
@export var jump_buffer_time: float = 0.1
# This timer tracks how long is left in the jump buffer window.
var jump_buffer_timer: float = 0.0

## How much you'll be slowed by sliding down a wall.
@export var wall_slide_slow_rate: float = 0.25
## This is the horizontal velocity of a wall jump.
@export var wall_jump_velocity: float = 400.0
## The time after a wall jump during which normal horizontal control is disabled.
@export var wall_jump_time: float = 0.2
# This timer tracks how long is left in the wall jump control disable window.
var wall_jump_timer = 0

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

# Debug Variables
const ON_COLOR := Color(1,1,1,1) # normal color
const OFF_COLOR := Color(0.2,0.2,0.2,1) # dim color for "off"
var jump_test_color : bool = false
# @onready var char_sprite : Sprite2D = $CollisionShape2D/Sprite2D

func _process(delta: float) -> void:
	# Best to be used for processing things which should happen immediately every frame,
	# such as input detection or jumping

	# Input Processing
	# If the character is respawning, freeze and skip all movement logic
	if cur_state == CHARACTER_STATE.RESPAWNING:
		velocity = Vector2.ZERO
		return

	# Update timers
	coyote_timer = max(0, coyote_timer - delta)
	wall_coyote_timer = max(0, wall_coyote_timer - delta)
	jump_buffer_timer = max(0, jump_buffer_timer - delta)
	wall_jump_timer = max(0, wall_jump_timer - delta)

	if Input.is_action_just_pressed("2d_platformer_jump"):
		jump_buffer_timer = jump_buffer_time
		print("Jump input registered at time %f", Time.get_ticks_msec())

	if is_on_floor():
		coyote_timer = coyote_time

	# Jumping Logic
	# If we have pressed the jump button recently, and are allowed to jump, do so.
	if jump_buffer_timer > 0:
		if coyote_timer > 0:
			_jump()

		elif wall_coyote_timer > 0 and not is_on_floor():
			velocity.x = 0
			velocity.x = (get_wall_normal().x * wall_jump_velocity)
			wall_jump_timer = wall_jump_time
			_jump()
		
	pass

func _physics_process(delta: float) -> void:
	# If the character is respawning, freeze and skip all movement logic
	if cur_state == CHARACTER_STATE.RESPAWNING:
		velocity = Vector2.ZERO
		return

	var acc = acceleration
	var fric = friction

	# Reset coyote time when on the floor, otherwise apply gravity
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		velocity.y += gravity_rate * delta * (wall_slide_slow_rate if (is_on_wall() and velocity.y > 0) else 1.0)
		acc = acceleration_air
		fric = friction_air
	
	if is_on_wall():
		wall_coyote_timer = coyote_time

	var input_axis = Input.get_axis("2d_platformer_move_left", "2d_platformer_move_right")
	
	# If we are not in the wall jump phase, allow normal horizontal control
	if wall_jump_timer <= 0:
		if input_axis != 0:
			velocity.x = lerp(velocity.x, input_axis * speed, acc * delta)
		else:
			velocity.x = lerp(velocity.x, 0.0, fric * delta)

	# print("Move and slide at time %f", Time.get_ticks_msec())	
	# print("Velocity: %s", velocity)
	move_and_slide()

	# Animation Logic. 
	# Will skip entirely if no anim_player is assigned.
	if anim_player:
		var new_anim_state: ANIM_STATE
		if is_on_floor():
			if input_axis != 0:
				new_anim_state = ANIM_STATE.WALK
			else:
				new_anim_state = ANIM_STATE.IDLE
		else:
			new_anim_state = ANIM_STATE.JUMP

		if new_anim_state != anim_state:
			anim_state = new_anim_state
			anim_player.stop()

			match new_anim_state:
				ANIM_STATE.IDLE:
					anim_player.play(IdleAnimString)
				ANIM_STATE.WALK:
					anim_player.play(WalkAnimString)
				ANIM_STATE.JUMP:
					anim_player.play(JumpAnimString)
		
		# TODO: Generalize
		if input_axis < 0:
			sprite.flip_h = false
		elif input_axis > 0:
			sprite.flip_h = true

# Jump logic, called when a jump is to be performed
func _jump():
	jump_test_color = !jump_test_color
	if jump_test_color:
		sprite.modulate = ON_COLOR
	else:
		sprite.modulate = OFF_COLOR
	
	# print("Jumping at %f", Time.get_ticks_msec())
	velocity.y = jump_velocity
	jump_buffer_timer = 0
	coyote_timer = 0
	wall_coyote_timer = 0

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
