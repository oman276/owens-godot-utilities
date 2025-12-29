extends OwenPickup
class_name OwenPickupThrowable

# OwenPickupThrowable
# A simple pickup object that can be thrown by the player.
# version 1.0.0
# last updated: 2025-12-29

# The force with which the object will be thrown.
@export var throw_force : float = 1000.0

# Called when the object is held and the player clicks.
func click_action():
	# If the object is not held, return.
	if parent_controller == null:
		push_warning("OwenPickupThrowable: Object is not held, cannot throw.")
		return
	
	# Get the mouse position and the player position.
	var mouse_pos = get_global_mouse_position()
	var player_pos = parent_controller.global_position
	
	# Drop the object.
	# Note that drop will reset the parent controller to null.
	# If you need to access variables from the parent controller, do it before calling drop.
	parent_controller.drop()
	super.click_action()
	
	# Calculate direction and apply impulse to throw the object.
	var direction = (mouse_pos - player_pos).normalized()
	apply_impulse(direction * throw_force)

# Called when the object is dropped by the player.
func drop():
	super.drop()
	# Reset the linear and angular velocity of the object.
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
