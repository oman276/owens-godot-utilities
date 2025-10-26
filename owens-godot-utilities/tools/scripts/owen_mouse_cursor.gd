extends Control
class_name OwenMouseCursor

# OwenMouseCursor
# A simple mouse cursor for 2D games.
# version 1.0.0
# last updated: 2025-10-26

# Usage Notes:
# This is intended to be used with the existing OwenMouseCursor object.
# You can instance this scene and add it to your UI layer to have a
# custom mouse cursor per-scene.

# The GameManager can also manage a global mouse cursor if desired,
# which will be controllable via the GameManager's custom_mouse_visible()
# function, and will remain persistent across level loads.
# It will attempt to load the object at a particular path, so make sure
# to set that path correctly in the GameManager script.

# The sprite used for the mouse cursor.
@onready var mouse_sprite : Sprite2D = $Sprite2D
# Locally tracking whether the cursor is active.
var is_active : bool = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(_delta):
	position = get_global_mouse_position()
