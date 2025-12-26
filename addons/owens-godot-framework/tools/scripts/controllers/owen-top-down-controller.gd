extends CharacterBody2D
class_name OwenTopDownController

# OwenTopDownController
# A simple top-down character controller for 2D games.
# version 1.0.1
# last updated: 2025-12-26

# PlayerMoveState is a globally queriable enum for the current state of the player's movement.
# You can use this to check if the player is free, dodging, etc to restrict or enable certain features.
# Add more states as needed.
enum PlayerMoveState {
	FREE,
	DODGING
}

# The current state of the player's movement.
var _move_state : PlayerMoveState = PlayerMoveState.FREE
# The vector direction of the player's dodge.
var _dodge_vector : Vector2 = Vector2(1, 0)

@export_category("Movement Properties")

@export_group("Basic Movement")
## The speed of the player's basic movement.
@export var speed : float = 300
## The acceleration of the player's basic movement.
@export var acceleration : float = 25
## The friction of the player's basic movement.
@export var friction : float = 10

@export_group("Sprinting")
## The speed multiplier of the player's sprinting movement.
@export var sprint_speed_multiplier : float = 1.5
## The acceleration multiplier of the player's sprinting movement.
@export var sprint_acceleration_multiplier : float = 1.5
## The friction multiplier of the player's sprinting movement.
@export var sprint_friction_multiplier : float = 0.5

@export_group("Dodging")
## The duration of the player's dodge.
@export var dodge_duration : float = 0.35
## The duration of the player's dodge while sprinting.
@export var dodge_duration_sprinting : float = 0.5
## The friction of the player's dodge.
@export var dodge_friction : float = 30.0
## The friction of the player's dodge while sprinting.
@export var dodge_friction_sprinting : float = 4000.0
## The speed multiplier of the player's dodge.
@export var dodge_speed_multiplier : float = 2.0
## The speed multiplier of the player's dodge while sprinting.
@export var dodge_speed_sprint_multiplier : float = 6
## A timer for the player's dodge.
@onready var dodge_timer : Timer = $DodgeTimer

func _ready():
	# Connect the dodge timer timeout signal to the _on_dodge_timer_timeout function.
	dodge_timer.timeout.connect(_on_dodge_timer_timeout)

# All input processing which should happen immediately and not wait for the next physics frame.
func _process(delta: float):
	# If the player is free and the dodge button is pressed, perform the dodge.
	if _move_state == PlayerMoveState.FREE and Input.is_action_just_pressed("topdown_dodge"):
		_dodge()

# All physics processing which should happen every physics frame.
func _physics_process(delta: float):
	# Match the current movement state to the appropriate movement logic.
	match _move_state:
		# Basic Movement, player is not in a special state like dodging.
		PlayerMoveState.FREE:
			var speed_values = _get_speed_values()
			var input_direction: Vector2 = Input.get_vector("topdown_move_left", "topdown_move_right", "topdown_move_up", "topdown_move_down")
			# Modify our velocity once we have all the info we need from input and speed calculations
			if input_direction != Vector2.ZERO:
				velocity = velocity.move_toward(input_direction * speed_values["speed"], speed_values["acceleration"] * delta)
			else:
				velocity = velocity.move_toward(Vector2(0, 0), speed_values["friction"] * delta)

		# Dodging, player is in a dodge state.
		PlayerMoveState.DODGING:
			velocity = velocity.move_toward(Vector2.ZERO, dodge_friction * delta)

	move_and_slide()

# We caclulate the current speed values based on several factors. 
# The speed is returned as one object we query for the values we want
func _get_speed_values() -> Dictionary:
	var _i_speed = speed * (sprint_speed_multiplier if is_sprinting() else 1.0)
	var _i_acceleration = acceleration * (sprint_acceleration_multiplier if is_sprinting() else 1.0)
	var _i_friction = friction * (sprint_friction_multiplier if is_sprinting() else 1.0)
	return {
		"speed" : _i_speed, 
		"acceleration" : _i_acceleration, 
		"friction" : _i_friction
	}

# When the dodge timer ends, reset the player state to FREE
func _on_dodge_timer_timeout():
	_move_state = PlayerMoveState.FREE

# Checks if the player is sprinting.
# This could be a simple boolean but it's a function for future flexibility.
func is_sprinting() -> bool:
	return Input.is_action_pressed("topdown_sprint")

# Performs the player's dodge.
func _dodge():
	# Set movement state to DODGING
	_move_state = PlayerMoveState.DODGING

	# Get the current movement vector from palyer input
	_dodge_vector = Input.get_vector("topdown_move_left", "topdown_move_right", "topdown_move_up", "topdown_move_down").normalized()
	
	# calculate velocity
	velocity = _dodge_vector * speed * (dodge_speed_sprint_multiplier if is_sprinting() else dodge_speed_multiplier)
	
	# Reset and set timer
	dodge_timer.stop()
	dodge_timer.start(dodge_duration_sprinting if is_sprinting() else dodge_duration)
