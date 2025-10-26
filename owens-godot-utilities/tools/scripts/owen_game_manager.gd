extends Node2D
class_name OwenGameManager

# OwenGameManager
# A simple game manager for handling level loading and global game state.
# version 1.0.0
# last updated: 2025-10-26

# Note: This class works best as a singleton (autoload) so it can be accessed globally.
# Some other utilities may depend on this being a singleton, accessible under the game "GameManager".

## Game State is a globally queriable enum for the current state of the game.
## You can use this to check if the game is paused, loading, etc to restrict or enable certain features.
## Add more states as needed.
enum GameState {
	DEFAULT,
	PAUSED,
	LOADING
}

## Levels is a queriable enum for the different levels in your game. 
## You can use this to check which level is active or load levels by enum instead of string.
## Add more levels as needed.
enum Levels {
	NONE,
	OWEN_TEST_LEVEL,
}

## This dictionary maps Levels enum values to their corresponding scene paths.
var level_path_dict : Dictionary = {
	Levels.NONE : "",
	Levels.OWEN_TEST_LEVEL : "res://test_game/scenes/test_scene.tscn",
}

## Loading
## These variables control the loading screen and basic behavior. 
## Meant to be used with my Loading utiliities, but you can implement your own loading screen logic if you want.

# Loading is set to off by default. Enable if if you have the rest of the loading screen system implemented.
var uses_loading_screen : bool = false
## This is the canvas layer that will be used for the loading screen.
var loading_canvas : CanvasLayer = null
## This is the string path to the loading canvas scene. Make sure to replace it yourself.
## TODO: Add Loading System
var loading_canvas_path : String = ""
# Time to wait before actually loading the level, to allow for fade in effects.
var loading_time : float = 0.1

# The initial level to load when the game starts.
var initial_level : Levels = Levels.OWEN_TEST_LEVEL
# The current global game state. The initial state is DEFAULT.
var current_global_state : GameState = GameState.DEFAULT
# The current level enum. Set to NONE by default. 
# Note that at the start of the game, the manager will load the initial_level instead.
var current_level : Levels = Levels.NONE
# The current level node instance, which we reference so we can unload it later.
var current_level_node : Node2D = null

# Mouse Cursor
# We can define a custom mouse cursor to replace the system cursor.
var mouse_cursor_path : String = "res://tools/scenes/OwenMouseCursor.tscn"
# Set to true if you want to use a custom mouse cursor and have the mouse cursor setup.
var load_custom_mouse : bool = true
# The mouse cursor node to be saved here.
var mouse_cursor : OwenMouseCursor = null

# Debug Controls
# Activate this book to allow reloading the current level with a keypress.
# The key is defined in the input map as "reload_current_level", by default R.
var debug_reload_level : bool = true

func _ready():
	if uses_loading_screen:
		if loading_canvas_path == "":
			push_error("OwenGameManager: uses_loading_screen is true but loading_canvas_path is empty.")
		else:
			loading_canvas = load(loading_canvas_path).instantiate()
			add_child(loading_canvas)
	
	if load_custom_mouse:
		var mouse_cursor_tscn = load(mouse_cursor_path)
		mouse_cursor = mouse_cursor_tscn.instantiate() as OwenMouseCursor
		add_child(mouse_cursor)

	load_level(initial_level)

## Externally callable function to load a level by enum.
func load_level(level: Levels) -> void:
	if level == current_level:
		return
	_force_load_level(level)

## Meant for reloading the current level.
## We usually have a check to make sure we don't reload the same level, but this function ignores that.
func reload_level() -> void:
	_force_load_level(current_level)

## Unload the current level and load a new one.
func _force_load_level(new_level: Levels):
	if uses_loading_screen and loading_canvas:
		loading_canvas.fade_in()
		await get_tree().create_timer(loading_time).timeout

	if current_level_node:
		remove_child(current_level_node)
		current_level_node.queue_free()
		current_level_node = null
		_on_unload_level(current_level)

	current_level = new_level

	var scene_str = level_path_dict[new_level]
	if scene_str != "":
		var scene = load(scene_str)
		current_level_node = scene.instantiate()
		add_child(current_level_node)

	_on_load_level(current_level)
	if uses_loading_screen and loading_canvas:
		loading_canvas.fade_out()

func custom_mouse_visible(mouse_visibility: bool) -> void:
	if not load_custom_mouse:
		push_warning("OwenGameManager: custom_mouse_visible called but load_custom_mouse is not enabled.")
		return
	mouse_cursor.visible = mouse_visibility

func _on_load_level(level : Levels) -> void:
	# Implement any logic you want to happen when a level is loaded here.
	# There may be general setup you want to do in all cases, or you can do 
	# something specific on certain levels.
	return

func _on_unload_level(level : Levels) -> void:
	# Implement any logic you want to happen when a level is unloaded here.
	# There may be general cleanup you want to do in all cases, or you can do 
	# something specific on certain levels.
	return

func _process(_delta):
	if debug_reload_level and Input.is_action_just_pressed("reload_current_level"):
		print("OwenGameManager: Reloading current level via debug keypress.")
		reload_level()
