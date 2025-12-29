extends OwenPickup
class_name OwenPickupThrowable

# OwenPickupThrowable
# A simple pickup object that can be thrown by the player.
# version 1.0.0
# last updated: 2025-12-29

# The force with which the object will be thrown.
@export var throw_force : float = 1000.0

# Called when the held and the player clicks.
func click_action():
	# Get the mouse position and the player position.
	var mouse_pos = get_global_mouse_position()
	var player_pos = parent_controller.global_position
	
	# Drop the object.
	parent_controller.drop()
	super.click_action()
	
	# Calculate direction and apply impulse to throw the object.
	var direction = (mouse_pos - player_pos).normalized()
	apply_impulse(direction * throw_force)

# Called when the object is picked up by the player.
# Currently passes to the super class, but could be overridden to add additional behavior.
func pick_up(_parent_controller : OwenPickupController):
	super.pick_up(_parent_controller)

# Called when the object is dropped by the player.
func drop():
	super.drop()
	# Reset the linear and angular velocity of the object.
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0

# Called when the object is next to be picked up by the player.
# Currently passes to the super class, but could be overridden to add additional behavior.
func next_to_pick_up(is_next : bool):
	super.next_to_pick_up(is_next)
