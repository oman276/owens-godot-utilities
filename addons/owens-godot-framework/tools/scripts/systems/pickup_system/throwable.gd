extends OwenPickup
class_name OwenPickupThrowable

@export var throw_force : float = 1000.0

func click_action():
	var mouse_pos = get_global_mouse_position()
	var player_pos = parent_controller.global_position
	
	parent_controller.drop()
	super.click_action()
	
	var direction = (mouse_pos - player_pos).normalized()
	apply_impulse(direction * throw_force)

func pick_up(_parent_controller : OwenPickupController):
	super.pick_up(_parent_controller)

func drop():
	super.drop()
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0

func next_to_pick_up(is_next : bool):
	super.next_to_pick_up(is_next)
