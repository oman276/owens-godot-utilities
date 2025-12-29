extends OwenPickup
class_name OwenPickupThrowable

@export var throw_force : float = 1000.0
var parent_player : OwenPickupController

func click_action(player_pos : Vector2, mouse_pos : Vector2):
	parent_player.drop()
	super.click_action(player_pos, mouse_pos)
	var direction = (mouse_pos - player_pos).normalized()
	apply_impulse(direction * throw_force)

func pick_up():
	super.pick_up()
	parent_player = player

func drop():
	super.drop()
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0

func next_to_pick_up(is_next : bool):
	super.next_to_pick_up(is_next)
