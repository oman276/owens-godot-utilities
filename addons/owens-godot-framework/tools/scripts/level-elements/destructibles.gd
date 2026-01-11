extends RigidBody2D
class_name OwenDestructible

@export var root_node: Node2D = null
@export var initial_health: float = 100.0

@export var particles_on_destruction: GPUParticles2D = null

var health: float

func _ready():
    health = initial_health

func reduce_health(amount: float):
    health -= amount
    if health <= 0:
        destroy()

func destroy():    
    if root_node:
        root_node.queue_free()
    else:
        queue_free()
