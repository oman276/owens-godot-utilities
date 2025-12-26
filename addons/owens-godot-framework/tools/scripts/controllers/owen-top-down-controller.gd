extends CharacterBody2D
class_name OwenTopDownController

# OwenTopDownController
# A simple top-down character controller for 2D games.
# version 1.0.0
# last updated: 2025-12-26

enum PlayerMoveState {
	FREE,
	DODGING
}

var _move_state : PlayerMoveState = PlayerMoveState.FREE
var _dodge_vector : Vector2 = Vector2(1, 0)

# TODO check to make sure we use all of these variables
@export_category("Movement Properties")

@export_group("Basic Movement")
@export var speed : float = 300
@export var acceleration : float = 25
@export var friction : float = 10

@export_group("Sprinting")
@export var sprint_speed_multiplier : float = 1.5
@export var sprint_acceleration_multiplier : float = 1.5
@export var sprint_friction_multiplier : float = 0.5

@export_group("Dodging")
@export var dodge_duration : float = 0.35
@export var dodge_duration_sprinting : float = 0.5
@export var dodge_friction : float = 30.0
@export var dodge_friction_sprinting : float = 4000.0
@export var dodge_speed_multiplier : float = 2.0
@export var dodge_speed_sprint_multiplier : float = 6
@onready var dodge_timer : Timer = $DodgeTimer

func _ready():
	dodge_timer.timeout.connect(_on_dodge_timer_timeout)

func _process(delta: float):
	if _move_state == PlayerMoveState.FREE and Input.is_action_just_pressed("topdown_dodge"):
		_dodge()

func _physics_process(delta: float):
	match _move_state:
		# Player-Controlled Movement
		PlayerMoveState.FREE:
			var speed_values = _get_speed_values()
			var input_direction: Vector2 = Input.get_vector("topdown_move_left", "topdown_move_right", "topdown_move_up", "topdown_move_down")
			if input_direction != Vector2.ZERO:
				velocity = velocity.move_toward(input_direction * speed_values["speed"], speed_values["acceleration"] * delta)
			else:
				velocity = velocity.move_toward(Vector2(0, 0), speed_values["friction"] * delta)

		# Dodging
		PlayerMoveState.DODGING:
			velocity = velocity.move_toward(Vector2.ZERO, dodge_friction * delta)

	move_and_slide()

func _get_speed_values() -> Dictionary:
	var _i_speed = speed * (sprint_speed_multiplier if is_sprinting() else 1.0)
	var _i_acceleration = acceleration * (sprint_acceleration_multiplier if is_sprinting() else 1.0)
	var _i_friction = friction * (sprint_friction_multiplier if is_sprinting() else 1.0)
	return {
		"speed" : _i_speed, 
		"acceleration" : _i_acceleration, 
		"friction" : _i_friction
	}

func _on_dodge_timer_timeout():
	_move_state = PlayerMoveState.FREE

func is_sprinting() -> bool:
	return Input.is_action_pressed("topdown_sprint")

func _dodge():
	_move_state = PlayerMoveState.DODGING
	_dodge_vector = Input.get_vector("topdown_move_left", "topdown_move_right", "topdown_move_up", "topdown_move_down").normalized()
	velocity = _dodge_vector * speed * (dodge_speed_sprint_multiplier if is_sprinting() else dodge_speed_multiplier)
	dodge_timer.stop()
	dodge_timer.start(dodge_duration_sprinting if is_sprinting() else dodge_duration)
