extends Control
class_name OwenMouseReticle

@onready var mouse_sprite : Sprite2D
var is_active : bool = false

func _ready():
	mouse_sprite = $MouseSprite

func _process(_delta):
	position = get_global_mouse_position()

