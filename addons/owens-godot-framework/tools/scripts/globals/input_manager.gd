extends Node
class_name OwenInputManager

# OwenInputManager
# A centralized manager for all input action strings in Owen's Godot Framework.
# This provides type-safe access to input actions and validates they exist in the InputMap.
# version 1.2.0
# last updated: 2025-12-27

## If enabled, missing input actions will throw errors instead of warnings.
## Recommended to enable during development, disable for production builds.
const strict_mode: bool = false

# ============================================================================
# VALIDATION CONFIGURATION
# ============================================================================
# Set these to false to skip validation for categories you're not using.
# This prevents warnings about missing input actions for unused control schemes.

## Whether to validate TopDown input actions on startup.
const validate_topdown: bool = true
## Whether to validate Platformer2D input actions on startup.
const validate_platformer: bool = true
## Whether to validate Debug input actions on startup.
const validate_debug: bool = true

# ============================================================================
# INPUT ACTION CONSTANTS
# ============================================================================
# Access these directly for simple Input calls:
# Example: Input.is_action_pressed(OwenInputManager.TopDown.SPRINT)

# INPUT ACTIONS
# Each class holds constants for the strings which should pass into Input calls.
# They can also hold helper functions for common input calls.

# TopDown input actions
class TopDown:
	## Single source of truth for all TopDown input action strings.
	const ACTIONS := {
		"DODGE": "topdown_dodge",
		"SPRINT": "topdown_sprint",
		"MOVE_LEFT": "topdown_move_left",
		"MOVE_RIGHT": "topdown_move_right",
		"MOVE_UP": "topdown_move_up",
		"MOVE_DOWN": "topdown_move_down",
	}
	
	# Read-only accessors for clean external API
	static var DODGE: String:
		get: return ACTIONS["DODGE"]
	static var SPRINT: String:
		get: return ACTIONS["SPRINT"]
	static var MOVE_LEFT: String:
		get: return ACTIONS["MOVE_LEFT"]
	static var MOVE_RIGHT: String:
		get: return ACTIONS["MOVE_RIGHT"]
	static var MOVE_UP: String:
		get: return ACTIONS["MOVE_UP"]
	static var MOVE_DOWN: String:
		get: return ACTIONS["MOVE_DOWN"]
	
	## Returns all action strings for validation.
	static func get_all_actions() -> Array:
		return ACTIONS.values()

	## Returns the movement vector for top-down movement.
	## Shorthand for Input.get_vector(move_left, move_right, move_up, move_down)
	static func get_movement_dir() -> Vector2:
		return Input.get_vector(
			MOVE_LEFT,
			MOVE_RIGHT, 
			MOVE_UP,
			MOVE_DOWN
		)

# Platformer input actions
class Platformer2D:
	## Single source of truth for all Platformer2D input action strings.
	const ACTIONS := {
		"JUMP": "2d_platformer_jump",
		"SPRINT": "2d_platformer_sprint",
		"MOVE_LEFT": "2d_platformer_move_left",
		"MOVE_RIGHT": "2d_platformer_move_right",
	}
	
	# Read-only accessors for clean external API
	static var JUMP: String:
		get: return ACTIONS["JUMP"]
	static var SPRINT: String:
		get: return ACTIONS["SPRINT"]
	static var MOVE_LEFT: String:
		get: return ACTIONS["MOVE_LEFT"]
	static var MOVE_RIGHT: String:
		get: return ACTIONS["MOVE_RIGHT"]
	
	## Returns all action strings for validation.
	static func get_all_actions() -> Array:
		return ACTIONS.values()

	## Returns the horizontal axis for platformer movement (-1 to 1).
	## Shorthand for Input.get_axis(move_left, move_right)
	static func get_movement_axis() -> float:
		return Input.get_axis(
			MOVE_LEFT,
			MOVE_RIGHT	
		)


class Pickup:
	const ACTIONS := {
		"PICK_UP": "pickup_pick_up",
		"DROP": "pickup_drop",
		"CLICK_ACTION": "pickup_click_action",
	}
	static var PICK_UP: String:
		get: return ACTIONS["PICK_UP"]
	static var DROP: String:
		get: return ACTIONS["DROP"]
	static var CLICK_ACTION: String:
		get: return ACTIONS["CLICK_ACTION"]
	
	## Returns all action strings for validation.
	static func get_all_actions() -> Array:
		return ACTIONS.values()

class Debug:
	## Single source of truth for all Debug input action strings.
	const ACTIONS := {
		"RELOAD_CURRENT_LEVEL": "reload_current_level",
	}
	
	# Read-only accessors for clean external API
	static var RELOAD_CURRENT_LEVEL: String:
		get: return ACTIONS["RELOAD_CURRENT_LEVEL"]
	
	## Returns all action strings for validation.
	static func get_all_actions() -> Array:
		return ACTIONS.values()

# VALIDATION SYSTEM

func _ready() -> void:
	_validate_all_input_actions()

## Validates all defined input actions exist in the InputMap
func _validate_all_input_actions() -> void:
	print("========================================")
	print("InputManager - Validation Report")
	print("========================================")
	
	var all_valid := true
	
	if validate_topdown:
		all_valid = _validate_category("TopDown", TopDown.get_all_actions()) and all_valid
	else:
		print("- TopDown: skipped (validation disabled)")
		
	if validate_platformer:
		all_valid = _validate_category("Platformer", Platformer2D.get_all_actions()) and all_valid
	else:
		print("- Platformer: skipped (validation disabled)")
		
	if validate_debug:
		all_valid = _validate_category("Debug", Debug.get_all_actions()) and all_valid
	else:
		print("- Debug: skipped (validation disabled)")

	print("========================================")
	
	if all_valid:
		print("All input actions validated successfully!")
	else:
		if strict_mode:
			push_error("InputManager: Validation failed! Missing actions detected. Fix InputMap or disable strict_mode.")
			get_tree().quit(1)
		else:
			push_warning("InputManager: Some actions are missing. Enable strict_mode to treat this as an error.")
	
	print("========================================")

## Validates a single category of input actions
func _validate_category(category_name: String, actions: Array) -> bool:
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
	_print_category_actions("TopDown", TopDown.get_all_actions())
	_print_category_actions("Platformer", Platformer2D.get_all_actions())
	_print_category_actions("Debug", Debug.get_all_actions())
	print("========================================")

func _print_category_actions(category_name: String, actions: Array) -> void:
	print("\n%s:" % category_name)
	for action in actions:
		print("  %s" % action)

