extends Node
class_name OwenInputManager

# OwenInputManager
# A centralized manager for all input action strings in Owen's Godot Framework.
# This provides type-safe access to input actions and validates they exist in the InputMap.
# version 1.0.0
# last updated: 2025-12-27

## If enabled, missing input actions will throw errors instead of warnings.
## Recommended to enable during development, disable for production builds.
@export var strict_mode: bool = false

# ============================================================================
# INPUT ACTION DICTIONARIES
# ============================================================================
# Access these directly for simple Input calls:
# Example: Input.is_action_pressed(InputManager.TopDown.SPRINT)


# INPUT ACTIONS
# Each class holds static variables for the strings which should pass into Input calls.
# They can also hold helper functions for common input calls.

# TopDown input actions
class TopDown:
	static var DODGE = "topdown_dodge"
	static var SPRINT = "topdown_sprint"
	static var MOVE_LEFT = "topdown_move_left"
	static var MOVE_RIGHT = "topdown_move_right"
	static var MOVE_UP = "topdown_move_up"
	static var MOVE_DOWN = "topdown_move_down"

	## Returns the movement vector for top-down movement.
	## Shorthand for Input.get_vector(move_left, move_right, move_up, move_down)
	static func get_movement_dir() -> Vector2:
		return Input.get_vector(
			MOVE_LEFT,
			MOVE_RIGHT, 
			MOVE_UP,
			MOVE_DOWN
		).normalized()

# Platformer input actions
class Platformer2D:
	static var JUMP = "2d_platformer_jump"
	static var SPRINT = "2d_platformer_sprint"
	static var MOVE_LEFT = "2d_platformer_move_left"
	static var MOVE_RIGHT = "2d_platformer_move_right"

	## Returns the horizontal axis for platformer movement (-1 to 1).
	## Shorthand for Input.get_axis(move_left, move_right)
	static func get_movement_axis() -> float:
		return Input.get_axis(
			MOVE_LEFT,
			MOVE_RIGHT	
		)

class Debug:
	static var RELOAD_CURRENT_LEVEL = "reload_current_level"

# VALIDATION SYSTEM
# These are the arrays of input actions that we cycle through for validation.
var _topdown_actions: Array[String] = [TopDown.MOVE_LEFT, TopDown.MOVE_RIGHT, TopDown.MOVE_UP, TopDown.MOVE_DOWN, TopDown.SPRINT, TopDown.DODGE]
var _platformer_actions: Array[String] = [Platformer2D.MOVE_LEFT, Platformer2D.MOVE_RIGHT, Platformer2D.JUMP, Platformer2D.SPRINT]
var _debug_actions: Array[String] = [Debug.RELOAD_CURRENT_LEVEL]

func _ready() -> void:
	_validate_all_input_actions()

## Validates all defined input actions exist in the InputMap
func _validate_all_input_actions() -> void:
	print("========================================")
	print("InputManager - Validation Report")
	print("========================================")
	
	var all_valid := true
	
	all_valid = _validate_category("TopDown", _topdown_actions) and all_valid
	all_valid = _validate_category("Platformer", _platformer_actions) and all_valid
	all_valid = _validate_category("Debug", _debug_actions) and all_valid

	print("========================================")
	
	if all_valid:
		print("✓ All input actions validated successfully!")
	else:
		if strict_mode:
			push_error("InputManager: Validation failed! Missing actions detected. Fix InputMap or disable strict_mode.")
			get_tree().quit(1)
		else:
			push_warning("InputManager: Some actions are missing. Enable strict_mode to treat this as an error.")
	
	print("========================================")

## Validates a single category of input actions
func _validate_category(category_name: String, actions: Array[String]) -> bool:
	var missing_actions: Array[String] = []
	
	for action_name in actions:
		if not InputMap.has_action(action_name):
			missing_actions.append(action_name)
	
	var total_actions := actions.size()
	var valid_actions := total_actions - missing_actions.size()
	
	if missing_actions.is_empty():
		print("✓ %s: %d/%d actions valid" % [category_name, valid_actions, total_actions])
		return true
	else:
		print("✗ %s: %d/%d actions valid" % [category_name, valid_actions, total_actions])
		for action in missing_actions:
			print("  Missing: %s" % action)
		return false

## Returns true if the specified action exists in the InputMap
func action_exists(action_name: String) -> bool:
	return InputMap.has_action(action_name)

## Prints all registered actions to the console (useful for debugging)
func print_all_actions() -> void:
	print("========================================")
	print("InputManager - All Registered Actions")
	print("========================================")
	_print_category_actions("TopDown", _topdown_actions)
	_print_category_actions("Platformer", _platformer_actions)
	print("========================================")

func _print_category_actions(category_name: String, actions: Array[String]) -> void:
	print("\n%s:" % category_name)
	for action in actions:
		print("  %s" % action)

