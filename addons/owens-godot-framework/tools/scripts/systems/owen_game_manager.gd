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

## This dictionary maps level names (strings) to their corresponding PackedScene objects.
## You can add new levels by editing this dictionary in the inspector.
## The key is the level name (string), and the value is the PackedScene to load.
@export var level_path_dict: Dictionary[String, PackedScene] = {
	"Platformer Test Level": preload("res://addons/owens-godot-framework/test_game_data/scenes/test_scene.tscn"),
}

## Loading
## These variables control the loading screen and basic behavior. 
## Meant to be used with my Loading utiliities, but you can implement your own loading screen logic if you want.

# Loading is set to off by default. Enable if if you have the rest of the loading screen system implemented.
var uses_loading_screen: bool = true
## This is the canvas layer that will be used for the loading screen.
var loading_canvas: CanvasLayer = null

# The loading canvas scene to instantiate. Set this in the editor by dragging the scene file here.
@export var loading_canvas_scene: PackedScene
# Time to wait before actually loading the level, to allow for fade in effects.
var loading_time: float = 0.5
# The loading canvas fade node, if it exists.
var loading_canvas_fade: OwenCanvasFade = null

# The initial level to load when the game starts. This should match a key in level_path_dict.
@export var initial_level: String = "Platformer Test Level"
# The current global game state. The initial state is DEFAULT.
var current_global_state: GameState = GameState.DEFAULT
# The current level name. Set to empty string by default. 
# Note that at the start of the game, the manager will load the initial_level instead.
var current_level: String = ""
# The current level node instance, which we reference so we can unload it later.
var current_level_node: Node2D = null

# Mouse Cursor
# We can define a custom mouse cursor to replace the system cursor.
# The mouse cursor scene to instantiate. Set this in the editor by dragging the scene file here.
@export var mouse_cursor_scene: PackedScene
# Set to true if you want to use a custom mouse cursor and have the mouse cursor setup.
var load_custom_mouse: bool = true
# The mouse cursor node to be saved here.
var mouse_cursor: OwenMouseCursor = null

# Debug Controls
# Activate this book to allow reloading the current level with a keypress.
# The key is defined in the input map as "reload_current_level", by default R.
var debug_reload_level: bool = true

func _ready():
	if uses_loading_screen:
		if not loading_canvas_scene:
			push_error("OwenGameManager: uses_loading_screen is true but loading_canvas_scene is not set. Please assign it in the editor.")
		else:
			loading_canvas = loading_canvas_scene.instantiate()
			add_child(loading_canvas)
			# Get reference to OwenCanvasFade if it exists
			loading_canvas_fade = _find_node_of_type(loading_canvas, "OwenCanvasFade") as OwenCanvasFade
	
	if load_custom_mouse:
		if not mouse_cursor_scene:
			push_error("OwenGameManager: load_custom_mouse is true but mouse_cursor_scene is not set. Please assign it in the editor.")
		else:
			mouse_cursor = mouse_cursor_scene.instantiate() as OwenMouseCursor
			add_child(mouse_cursor)

	load_level(initial_level)

## Externally callable function to load a level by name.
## The level name should match a key in the level_path_dict dictionary.
func load_level(level: String) -> void:
	if level == current_level:
		return
	_force_load_level(level)

## Meant for reloading the current level.
## We usually have a check to make sure we don't reload the same level, but this function ignores that.
func reload_level() -> void:
	_force_load_level(current_level)

## Unload the current level and load a new one.
func _force_load_level(new_level: String):
	if uses_loading_screen and loading_canvas:
		if loading_canvas_fade:
			loading_canvas_fade.fade_in()
		await get_tree().create_timer(loading_time).timeout

	if current_level_node:
		remove_child(current_level_node)
		current_level_node.queue_free()
		current_level_node = null
		_on_unload_level(current_level)

	current_level = new_level

	if new_level in level_path_dict:
		var scene: PackedScene = level_path_dict[new_level]
		if scene:
			current_level_node = scene.instantiate()
			add_child(current_level_node)
		else:
			push_error("OwenGameManager: Level '%s' has a null PackedScene in level_path_dict." % new_level)
	else:
		push_error("OwenGameManager: Level '%s' not found in level_path_dict." % new_level)

	_on_load_level(current_level)
	if uses_loading_screen and loading_canvas_fade:
		loading_canvas_fade.fade_out()

func custom_mouse_visible(mouse_visibility: bool) -> void:
	if not load_custom_mouse:
		push_warning("OwenGameManager: custom_mouse_visible called but load_custom_mouse is not enabled.")
		return
	mouse_cursor.visible = mouse_visibility

func _on_load_level(level: String) -> void:
	# Implement any logic you want to happen when a level is loaded here.
	# There may be general setup you want to do in all cases, or you can do 
	# something specific on certain levels.
	return

func _on_unload_level(level: String) -> void:
	# Implement any logic you want to happen when a level is unloaded here.
	# There may be general cleanup you want to do in all cases, or you can do 
	# something specific on certain levels.
	return

# We use this to process debug inputs.
func _process(_delta):
	if debug_reload_level and Input.is_action_just_pressed(OwenInputManager.Debug.RELOAD_CURRENT_LEVEL):
		print("OwenGameManager: Reloading current level via debug keypress.")
		reload_level()

# A helper function to find a node of a specific type in the scene tree.
func _find_node_of_type(parent: Node, type: String) -> Node:
	if parent.get_class() == type or parent is OwenCanvasFade:
		return parent
	for child in parent.get_children():
		var result = _find_node_of_type(child, type)
		if result:
			return result
	return null


func get_current_level_node() -> Node2D:
	if current_level_node == null:
		push_error("OwenGameManager: current_level_node is null, cannot get current level node.")
		return null
	return current_level_node
