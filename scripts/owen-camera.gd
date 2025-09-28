class_name OwenCamera
extends Camera2D

# OwenCamera
# A simple 2D camera that can smoothly follow a target and clamp to boundaries.
# version 1.0
# last updated: 2025-09-28

@export_category("Targeting")
## The node the camera will try to follow. If null, it will try to find a target on its own.
@export var target: Node2D

## If your target is a physics object, enable this to have the camera tick in _physics_process instead of _process.
## If your camera is jittery, try enabling this.
@export var target_is_physics: bool = false

@export_category("Smoothing")
## Enable or disable smoothing when following the target.
## If disabled, the camera will snap to the target's position.
@export var smoothing_enabled: bool = true
## The speed at which the camera moves to the target's position if smoothing is enabled. Higher values are faster.
@export var smoothing_speed: float = 5.0

@export_category("Clamping")
## The bottom-left corner of the rectangle the camera is allowed to move within.
## Note that the the y value is the maximum y (since y increases downwards in Godot).
## Use -INF, INF for no limit.
@export var bottom_left_clamp: Vector2 = Vector2(-INF, INF)
## The top-right corner of the rectangle the camera is allowed to move within.
## Note that the the y value is the minimum y (since y increases upwards in Godot).
## Use INF, -INF for no limit.
@export var top_right_clamp: Vector2 = Vector2(INF, -INF)

@export_category("Zoom")
## The base zoom level of the camera. 
## Overriden on start to the camera's initial zoom level.
var base_zoom: Vector2 = Vector2(1, 1)
## The maximum additional zoom the camera can add to the base zoom.
@export var max_zoom_add: Vector2 = Vector2(5, 5)
## The speed at which the camera zooms in and out to the target zoom level.
@export var zoom_speed: float = 5

func _ready():
	base_zoom = zoom
	_try_find_target()
	
# Follow the target in the appropriate process function
func _physics_process(delta: float) -> void:
	if target_is_physics:
		_follow_target(delta)

func _process(delta: float) -> void:
	if not target_is_physics:
		_follow_target(delta)

# Function for moving the camera to follow the target, depending on settings
func _follow_target(delta):
	# If the target is set, attempt to follow it
	if target: 
		# Clamp the target position within the defined boundaries
		var target_position = target.global_position
		target_position.x = clamp(target_position.x, bottom_left_clamp.x, top_right_clamp.x)
		target_position.y = clamp(target_position.y, top_right_clamp.y, bottom_left_clamp.y)

		# Move the camera towards the target position, with optional smoothing
		if smoothing_enabled:
			global_position = global_position.lerp(target_position, smoothing_speed * delta)
		else:
			global_position = target_position

		# Adjust zoom level
		var target_zoom: Vector2 = base_zoom + _add_zoom()
		zoom = lerp(zoom, target_zoom, zoom_speed * delta)
			
	else:
		_try_find_target()

# Attempt to find a target if none is set. Implement your own logic here.
func _try_find_target():
	if target:
		return
	# implement finding target here

# Add zoom based on certain conditions. Implement your own logic here.
func _add_zoom():
	# determine how and when you want to add zoom here
	return Vector2(0, 0)