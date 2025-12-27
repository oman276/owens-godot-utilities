extends CharacterBody2D
class_name OwenTopDownController

# OwenTopDownController
# A simple top-down character controller for 2D games.
# version 1.0.2
# last updated: 2025-12-27

# PlayerMoveState is a globally queriable enum for the current state of the player's movement.
# You can use this to check if the player is free, dodging, etc to restrict or enable certain features.
# Add more states as needed.
enum PlayerMoveState {
	FREE,
	DODGING
}

# The current state of the player's movement.
var _move_state : PlayerMoveState = PlayerMoveState.FREE

@export_category("Movement Properties")

@export_group("Basic Movement")
## The speed of the player's basic movement.
@export var speed : float = 300
## The acceleration of the player's basic movement.
@export var acceleration : float = 25
## The friction of the player's basic movement.
@export var friction : float = 10

var _speed_values: Dictionary = {
	"speed" : 0,
	"acceleration" : 0,
	"friction" : 0
}

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
	if not dodge_timer:
		push_error("OwenTopDownController: Dodge timer not found.")
		return
	# Connect the dodge timer timeout signal to the _on_dodge_timer_timeout function.
	dodge_timer.timeout.connect(_on_dodge_timer_timeout)

# All input processing which should happen immediately and not wait for the next physics frame.
func _process(_delta: float):	
	# If the player is free and the dodge button is pressed, perform the dodge.
	if _move_state == PlayerMoveState.FREE and Input.is_action_just_pressed(OwenInputManager.TopDown.DODGE):
		_dodge()

# All physics processing which should happen every physics frame.
func _physics_process(delta: float):
	# Match the current movement state to the appropriate movement logic.
	match _move_state:
		# Basic Movement, player is not in a special state like dodging.
		PlayerMoveState.FREE:
			_update_speed_values()
			var input_direction = _get_input_direction()
			# Modify our velocity once we have all the info we need from input and speed calculations
			if input_direction != Vector2.ZERO:
				velocity = velocity.move_toward(input_direction * _speed_values["speed"], _speed_values["acceleration"] * delta)
			else:
				velocity = velocity.move_toward(Vector2.ZERO, _speed_values["friction"] * delta)

		# Dodging, player is in a dodge state.
		PlayerMoveState.DODGING:
			velocity = velocity.move_toward(Vector2.ZERO, (dodge_friction_sprinting if is_sprinting() else dodge_friction) * delta)

	move_and_slide()

# We calculate the current speed values based on several factors. 
func _update_speed_values() -> void:
	_speed_values["speed"] = speed * (sprint_speed_multiplier if is_sprinting() else 1.0)
	_speed_values["acceleration"] = acceleration * (sprint_acceleration_multiplier if is_sprinting() else 1.0)
	_speed_values["friction"] = friction * (sprint_friction_multiplier if is_sprinting() else 1.0)

func _get_input_direction() -> Vector2:
	return OwenInputManager.TopDown.get_movement_dir()

# When the dodge timer ends, reset the player state to FREE
func _on_dodge_timer_timeout():
	_move_state = PlayerMoveState.FREE

# Checks if the player is sprinting.
# This could be a simple boolean but it's a function for future flexibility.
func is_sprinting() -> bool:
	return Input.is_action_pressed(OwenInputManager.TopDown.SPRINT)

# Performs the player's dodge.
func _dodge():
	# Get the current movement vector from player input
	var dodge_vector = _get_input_direction()
	# We don't want to dodge if we are already dodging or if the dodge vector is zero
	if _move_state == PlayerMoveState.DODGING or dodge_vector == Vector2.ZERO:
		return
	# Set movement state to DODGING
	_move_state = PlayerMoveState.DODGING
	# calculate velocity
	velocity = dodge_vector * speed * (dodge_speed_sprint_multiplier if is_sprinting() else dodge_speed_multiplier)
	# Reset and set timer
	dodge_timer.stop()
	dodge_timer.start(dodge_duration_sprinting if is_sprinting() else dodge_duration)
