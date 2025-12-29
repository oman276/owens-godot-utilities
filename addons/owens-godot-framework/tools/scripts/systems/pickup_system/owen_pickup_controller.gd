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
		look_at(get_global_mouse_position())

	#Input processing
	if Input.is_action_just_pressed(OwenInputManager.Pickup.PICK_UP):
		_pick_up()
	elif Input.is_action_just_pressed(OwenInputManager.Pickup.DROP):
		_drop()
	if Input.is_action_just_pressed(OwenInputManager.Pickup.CLICK_ACTION):
		if held_object != null:
			held_object.click_action()

func _pick_up():
	print("Pick up input pressed")
	var item = _pop_pickup_from_list()
	if item != null:
		print("Item found: ", item.name)
		if held_object != null:
			print("Dropped item: ", held_object.name)
			_drop()
			await get_tree().process_frame
		print("Picking up item: ", item.name)
		held_object = item
		held_object.pick_up(self)	
		print("Picked up item: ", held_object.name)

		GameManager.custom_mouse_visible(true)
		print("Mouse visible: true")
		var original_scale = held_object.global_scale
		if held_object.get_parent() != null:
			GameManager.get_current_level_node().remove_child(held_object)
		HoldPoint.add_child(held_object)
		held_object.global_scale = original_scale
		held_object.global_position = HoldPoint.global_position
		held_object.rotation = 0

func drop() -> Node2D:
	return _drop()

func _drop() -> Node2D:
	print("Drop input pressed")
	if held_object != null:
		print("Dropping item: ", held_object.name)
		var original_scale = held_object.global_scale
		HoldPoint.remove_child(held_object)
		GameManager.get_current_level_node().add_child(held_object)
		held_object.global_scale = original_scale
		held_object.global_position = HoldPoint.global_position
		held_object.rotation = 0
		held_object.drop()
		print("Dropped item: ", held_object.name)
		var original_held = held_object
		held_object = null
		GameManager.custom_mouse_visible(false)
		print("Mouse visible: false")
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
		temp_held.click_action()
