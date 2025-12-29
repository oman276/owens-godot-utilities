extends RigidBody2D
class_name OwenPickup

# OwenPickup
# A simple pickup object that can be picked up and dropped by the player.
# version 1.0.0
# last updated: 2025-12-29

# The controller that is currently holding the object.
# This is set when the object is picked up by the player.
# This is null when the object is dropped by the player.
var parent_controller : OwenPickupController = null

# Overridable function for an action that can be performed on an object on click.
func click_action():
	pass

# Called when the object is picked up by the player.
func pick_up(_parent_controller : OwenPickupController):
	# If the object is already held, return.
	if parent_controller != null:
		push_warning("OwenPickup: Object is already held, cannot pick up again.")
		return

	# If the parent controller is null, return.
	if _parent_controller == null:
		push_warning("OwenPickup: Parent controller is null, cannot pick up.")
		return

	# Set the parent controller to the new parent controller.
	parent_controller = _parent_controller
	# Stop applying RigidBody2D physics to the object.
	freeze = true

	# Disable collision with other objects.
	set_collision_layer_value(1, false)  # Disable collision layer 1
	set_collision_mask_value(1, false)   # Disable collision mask 1

# Called when the object is dropped by the player.
func drop():
	parent_controller = null
	# Resume applying RigidBody2D physics to the object.
	freeze = false

	# Re-enable collision with other objects.
	set_collision_layer_value(1, true)   # Re-enable collision layer 1
	set_collision_mask_value(1, true)    # Re-enable collision mask 1

# Called when the object is next to be picked up by the player.
# Not used for anything now, but can be used to highlight the object in some way.
func next_to_pick_up(_is_next : bool = false):
	pass