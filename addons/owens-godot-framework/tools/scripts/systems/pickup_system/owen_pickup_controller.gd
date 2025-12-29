extends Node2D
class_name OwenPickupController

# OwenPickupController
# A simple pickup system controller for 2D games.
# version 1.0.0
# last updated: 2025-12-29

# The point at which the held object will be placed.
@onready var HoldPoint : Node2D = $HoldPoint
# The object that is currently held by the player.
var held_object : OwenPickup = null
# The object that is next to be picked up by the player.
var next_held_object : OwenPickup = null
# A list of objects that are currently in the player's pickup zone.
var nearby_object_list : Array = []

func _ready() -> void:
	GameManager.custom_mouse_visible(false)
	$ItemDetectionZone.body_entered.connect(_on_item_detection_zone_body_entered)
	$ItemDetectionZone.body_exited.connect(_on_item_detection_zone_body_exited)

func _process(_delta):
	if held_object != null:
		look_at(get_global_mouse_position())

	#Input processing
	if Input.is_action_just_pressed(OwenInputManager.Pickup.PICK_UP):
		_pick_up()
	elif Input.is_action_just_pressed(OwenInputManager.Pickup.DROP):
		_drop()
	if Input.is_action_just_pressed(OwenInputManager.Pickup.CLICK_ACTION):
		if held_object != null:
			held_object.click_action()

# Pick up the first object in the list of nearby objects.
func _pick_up():
	# Get the first object in the list of nearby objects.
	var item = _pop_pickup_from_list()
	if item != null:
		# If there is already an object held, drop it.
		if held_object != null:
			_drop()
			await get_tree().process_frame
		# Set the held object to the new object.
		held_object = item
		held_object.pick_up(self)	
		
		# Make the mouse visible.
		GameManager.custom_mouse_visible(true)

		# Add the object as a child of the hold point, respecting original scale
		var original_scale = held_object.global_scale
		if held_object.get_parent() != null:
			GameManager.get_current_level_node().remove_child(held_object)
		HoldPoint.add_child(held_object)
		held_object.global_scale = original_scale
		held_object.global_position = HoldPoint.global_position
		held_object.rotation = 0

# External access drop function.
func drop() -> Node2D:
	return _drop()

# Drop the current held object.
func _drop() -> Node2D:
	# If there is an object held, drop it.
	if held_object != null:
		# Get the original scale of the held object.
		var original_scale = held_object.global_scale
		HoldPoint.remove_child(held_object)
		GameManager.get_current_level_node().add_child(held_object)
		held_object.global_scale = original_scale
		held_object.global_position = HoldPoint.global_position
		held_object.rotation = 0
		held_object.drop()
		var original_held = held_object
		held_object = null
		GameManager.custom_mouse_visible(false)
		return original_held
	
	# If there is no object held, return null.
	return null

# Add an object to the list of nearby objects.
func _add_pickup_to_list(pickup: OwenPickup):
	nearby_object_list.append(pickup)

# Remove and return the first object in the list of nearby objects.
func _pop_pickup_from_list() -> OwenPickup:
	if nearby_object_list.size() > 0:
		return nearby_object_list.pop_front()
	return null

# Safely get the first object in the list of nearby objects.
func _peek_pickup_from_list() -> OwenPickup:
	if nearby_object_list.size() > 0:
		return nearby_object_list[0]
	return null

# Remove an object from the list of nearby objects.
func _remove_pickup_from_list(pickup: OwenPickup):
	nearby_object_list.erase(pickup)

# Update the next object to be picked up if player presses the pickup button.
func _update_next_pickup():
	var item = _peek_pickup_from_list()
	# If a new item is next on the list (ie not null and not next_held_object)
	if item != null and item != next_held_object:
		# Disable the previous next object from being picked up.
		if next_held_object != null:
			next_held_object.next_to_pick_up(false)
		# Enable the new next object to be picked up.
		next_held_object = item
		next_held_object.next_to_pick_up(true)
	# If the list is empty and there is a next object, disable it.
	elif item == null and next_held_object != null:
		# Disable the current next object from being picked up.
		next_held_object.next_to_pick_up(false)
		next_held_object = null

# When an object enters the player's pickup zone, add it to the list of held objects.
# Update the next object to be picked up.
func _on_item_detection_zone_body_entered(body : Node2D) -> void:
	if body is OwenPickup:
		_add_pickup_to_list(body)
		_update_next_pickup()

# When an object exits the player's pickup zone, remove it from the list of held objects.
# Update the next object to be picked up.
func _on_item_detection_zone_body_exited(body:Node2D) -> void:
	if body is OwenPickup:
		_remove_pickup_from_list(body)
		_update_next_pickup()

# When the player clicks the action button, call the click action on the held object.
func _on_click_action() -> void:
	# This should be checked by caller, but no harm in checking here too.
	if held_object != null:
		var temp_held = held_object
		temp_held.click_action()
