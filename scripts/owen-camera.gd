class_name OwenCamera
extends Camera2D

@export var target: Node2D
@export var target_is_physics: bool = false

@export var smoothing_enabled: bool = true
@export var smoothing_speed: float = 5.0

@export var bottom_left_clamp: Vector2 = Vector2(-INF, INF)
@export var top_right_clamp: Vector2 = Vector2(INF, -INF)

var base_zoom: Vector2 = Vector2(1, 1)
@export var max_zoom_add: Vector2 = Vector2(5, 5)
@export var zoom_speed: float = 5

func _ready():
	base_zoom = zoom
	_try_find_target()

func _physics_process(delta: float) -> void:
	if target_is_physics:
		_follow_target(delta)

func _process(delta: float) -> void:
	if not target_is_physics:
		_follow_target(delta)

func _follow_target(delta):
	if target:
		var target_position = target.global_position
		target_position.x = clamp(target_position.x, bottom_left_clamp.x, top_right_clamp.x)
		target_position.y = clamp(target_position.y, top_right_clamp.y, bottom_left_clamp.y)

		if smoothing_enabled:
			global_position = global_position.lerp(target_position, smoothing_speed * delta)
		else:
			global_position = target_position

		var target_zoom: Vector2 = base_zoom + _add_zoom()
		zoom = lerp(zoom, target_zoom, zoom_speed * delta)
			
	else:
		_try_find_target()


func _try_find_target():
	if target:
		return
	# implement finding target here

func _add_zoom():
	# determine how and when you want to add zoom here
	return Vector2(0, 0)