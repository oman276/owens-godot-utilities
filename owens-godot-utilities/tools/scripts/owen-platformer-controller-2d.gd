class_name OwenPlatformerController2D
extends CharacterBody2D

# OwenPlatformerController2D
# A simple platformer character controller for 2D games.
# version 1.0
# last updated: 2025-10-19

## Your maximum horizontal speed.
@export var speed: float = 300.0
## How quickly a character reaches their max speed
@export var acceleration: float = 25.0
@export var air_acceleration: float = 10.0
## How quickly a character stops when input is not given
@export var friction: float = 25.0
@export var air_friction: float = 10.0

## This is the initial upwards velocity of a jump
@export var jump_velocity: float = -400.0

## Coyote time allows you to jump shortly after leaving a ledge to make it feel less punishing
@export var coyote_time: float = 0.1
var coyote_timer: float = 0.0
var wall_coyote_timer: float = 0.0

## Allows jump inputs to be buffered and used before you actually hit the ground
@export var jump_buffer_time: float = 0.1
var jump_buffer_timer: float = 0.0

## The gravity rate affects how quickly the character falls in cm/s. In real life, this is 980 cm/s
@export var gravity_rate: float = 980

## How much you'll be slowed by sliding down a wall
@export var wall_slide_slow_rate: float = 0.25
## This is the horizontal velocity of a wall jump
@export var wall_jump_velocity: float = 400.0
@export var wall_jump_time: float = 0.2
var wall_jump_timer = 0

# Animation Variables
@onready var anim_player: AnimationPlayer = $AnimationPlayer
enum ANIM_STATE {
	IDLE,
	WALK,
	JUMP
}
var anim_state: ANIM_STATE = ANIM_STATE.IDLE

enum CHARACTER_STATE {
	ACTIVE,
	RESPAWNING,
	TRANSITIONING
}
var cur_state: CHARACTER_STATE = CHARACTER_STATE.ACTIVE

func _physics_process(delta: float) -> void:
	if cur_state == CHARACTER_STATE.RESPAWNING:
		velocity = Vector2.ZERO
		return

	if cur_state == CHARACTER_STATE.TRANSITIONING:
		velocity = Vector2(0, -1) * speed * 2
		move_and_slide()
		return

	var acc = acceleration
	var fric = friction

	if is_on_floor():
		coyote_timer = coyote_time
	else:
		velocity.y += gravity_rate * delta * (wall_slide_slow_rate if (is_on_wall() and velocity.y > 0) else 1.0)
		acc = air_acceleration
		fric = air_friction

	coyote_timer = max(0, coyote_timer - delta)
	wall_coyote_timer = max(0, wall_coyote_timer - delta)
	jump_buffer_timer = max(0, jump_buffer_timer - delta)
	wall_jump_timer = max(0, wall_jump_timer - delta)
	
	if is_on_wall():
		wall_coyote_timer = coyote_time

	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time

	var input_axis = Input.get_axis("move_left", "move_right")

	if jump_buffer_timer > 0:
		if coyote_timer > 0:
			_jump()

		elif wall_coyote_timer > 0 and not is_on_floor():
			velocity.x = 0
			velocity.x = (get_wall_normal().x * wall_jump_velocity)
			wall_jump_timer = wall_jump_time
			_jump()
	
	if wall_jump_timer <= 0:
		if input_axis != 0:
			velocity.x = lerp(velocity.x, input_axis * speed, acc * delta)
		else:
			velocity.x = lerp(velocity.x, 0.0, fric * delta)
			
	move_and_slide()

	# animation
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
		# TODO: remove Nicole references
		match new_anim_state:
			ANIM_STATE.IDLE:
				anim_player.play("nicole_idle")
			ANIM_STATE.WALK:
				anim_player.play("nicole_walk")
			ANIM_STATE.JUMP:
				anim_player.play("nicole_jump")
		
	if input_axis < 0:
		$Sprite2D.flip_h = false
	elif input_axis > 0:
		$Sprite2D.flip_h = true

func _jump():
	velocity.y = jump_velocity
	jump_buffer_timer = 0
	coyote_timer = 0
	wall_coyote_timer = 0

func hit():
	if cur_state == CHARACTER_STATE.ACTIVE:
		set_state(CHARACTER_STATE.RESPAWNING)
		GameManager.reload_level()

func set_state(state: CHARACTER_STATE) -> void:
	if cur_state == state:
		return

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
