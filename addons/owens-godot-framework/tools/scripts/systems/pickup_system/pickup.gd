extends RigidBody2D
class_name OwenPickup

var base_scale : Vector2 = Vector2(1, 1)
@export var held_scale : Vector2 = Vector2(1, 1)
var player_parent : Node2D = null

func click_action(player_pos : Vector2, mouse_pos : Vector2):
	pass

func pick_up():
	freeze = true
	set_collision_layer_value(1, false)  # Disable collision layer 1
	set_collision_layer_value(2, false)  # Disable collision layer 2
	set_collision_mask_value(1, false)   # Disable collision mask 1
	set_collision_mask_value(2, false)   # Disable collision mask 2

func drop():
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