extends RigidBody2D
class_name OwenPickup

var parent_controller : OwenPickupController = null

func click_action():
	pass

func pick_up(_parent_controller : OwenPickupController):
	parent_controller = _parent_controller
	freeze = true
	set_collision_layer_value(1, false)  # Disable collision layer 1
	set_collision_layer_value(2, false)  # Disable collision layer 2
	set_collision_mask_value(1, false)   # Disable collision mask 1
	set_collision_mask_value(2, false)   # Disable collision mask 2

func drop():
	parent_controller = null
	freeze = false
	set_collision_layer_value(1, true)   # Re-enable collision layer 1
	set_collision_layer_value(2, true)   # Re-enable collision layer 2
	set_collision_mask_value(1, true)    # Re-enable collision mask 1
	set_collision_mask_value(2, true)    # Re-enable collision mask 2

func next_to_pick_up(is_next : bool):
	if is_next:
		print(name, "This is next to pick up")
	else:
		print(name, "This is no longer next to pick up")