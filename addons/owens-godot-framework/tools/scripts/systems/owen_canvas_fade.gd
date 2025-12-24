extends Node
class_name OwenCanvasFade

#TODO: Add usage notes

# OwenCanvasFade
# A simple 2D canvas fade effect manager
# version 1.0
# last updated: 2025-10-26

## The list of Control nodes to fade in and out.
## When this object's fade_in() or fade_out() functions are called,
## it will apply the fade effect to all items in this list.
@export var items_to_fade : Array[Control] = []
## The duration of the fade in and fade out effects, in seconds.
@export var fade_duration : float = 0.2

func _ready():
	if items_to_fade.is_empty():
		push_error("OwenCanvasFade: items_to_fade is empty.")
		return

	for item in items_to_fade:
		item.modulate.a = 0

func fade_in():
	if items_to_fade.is_empty():
		push_error("OwenCanvasFade: items_to_fade is empty.")
		return

	for item in items_to_fade:
		item.visible = true

	var tween = get_tree().create_tween()
	for item in items_to_fade:
		tween.tween_property(item, "modulate:a", 1.0, fade_duration)

func fade_out():
	if items_to_fade.is_empty():
		push_error("OwenCanvasFade: items_to_fade is empty.")
		return

	for item in items_to_fade:
		item.visible = true
	
	var tween = get_tree().create_tween()
	for item in items_to_fade:
		tween.tween_property(item, "modulate:a", 0.0, fade_duration)

	await get_tree().create_timer(fade_duration).timeout

	for item in items_to_fade:
		item.visible = false