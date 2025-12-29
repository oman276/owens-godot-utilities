extends Node2D
class_name OwenPickupController

@onready var HoldPoint : Node2D = $HoldPoint
var held_object : OwenPickup = null
var next_held_object : OwenPickup = null
var held_object_list : Array = []

func _ready() -> void:
	print("OwenPickupController ready")
	GameManager.custom_mouse_visible(false)
	$ItemDetectionZone.body_entered.connect(_on_item_detection_zone_body_entered)
	$ItemDetectionZone.body_exited.connect(_on_item_detection_zone_body_exited)

func _process(_delta):
	if held_object != null:
		HoldPoint.look_at(get_global_mouse_position())

	#Input processing
	if Input.is_action_just_pressed(OwenInputManager.Pickup.PICK_UP):
		_pick_up()
	elif Input.is_action_just_pressed(OwenInputManager.Pickup.DROP):
		_drop()
	if Input.is_action_just_pressed(OwenInputManager.Pickup.CLICK_ACTION):
		if held_object != null:
			held_object.click_action(global_position, get_global_mouse_position())

func _pick_up():
	var item = _pop_pickup_from_list()
	if item != null:
		if held_object != null:
			_drop()
			await get_tree().process_frame
		held_object = item
		held_object.pick_up()

		GameManager.custom_mouse_visible(true)

		if held_object.get_parent() != null:
			GameManager.get_current_level_node().remove_child(held_object)
		HoldPoint.add_child(held_object)
		held_object.global_position = HoldPoint.global_position
		held_object.rotation = 0

func drop() -> Node2D:
	return _drop()

func _drop() -> Node2D:
	if held_object != null:
		HoldPoint.remove_child(held_object)
		GameManager.get_current_level_node().add_child(held_object)
		held_object.global_position = HoldPoint.global_position
		held_object.rotation = 0
		held_object.drop()
		var original_held = held_object
		held_object = null
		GameManager.mouse_visible(false)
		return original_held
	return null

func _add_pickup_to_list(pickup: OwenPickup):
	held_object_list.append(pickup)

func _pop_pickup_from_list() -> OwenPickup:
	if held_object_list.size() > 0:
		return held_object_list.pop_front()
	return null

func _peek_pickup_from_list() -> OwenPickup:
	if held_object_list.size() > 0:
		return held_object_list[0]
	return null

func _remove_pickup_from_list(pickup: OwenPickup):
	held_object_list.erase(pickup)

func _update_next_pickup():
	var item = _peek_pickup_from_list()
	if item != null and item != next_held_object:
		if next_held_object != null:
			next_held_object.next_to_pick_up(false)
		next_held_object = item
		next_held_object.next_to_pick_up(true)
	elif item == null and next_held_object != null:
		next_held_object.next_to_pick_up(false)
		next_held_object = null

func _on_item_detection_zone_body_entered(body : Node2D) -> void:
	print("Item detection zone body entered: ", body.name)
	if body is OwenPickup:
		_add_pickup_to_list(body)
		_update_next_pickup()

func _on_item_detection_zone_body_exited(body:Node2D) -> void:
	print("Item detection zone body exited: ", body.name)
	if body is OwenPickup:
		_remove_pickup_from_list(body)
		_update_next_pickup()

func _on_click_action() -> void:
	print("Click action")
	if held_object != null:
		var temp_held = held_object
		temp_held.click_action(global_position, get_global_mouse_position())
