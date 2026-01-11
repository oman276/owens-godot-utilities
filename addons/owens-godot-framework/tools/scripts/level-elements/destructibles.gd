extends RigidBody2D
class_name OwenDestructible

# OwenDestructible
# A simple object which can be destroyed when its health reaches zero.
# version 1.0.0
# last updated: 2026-01-11

@export var root_node: Node2D = null
@export var initial_health: float = 100.0

@export var particles_on_destruction: PackedScene = null

var health: float

func _ready():
    health = initial_health

func reduce_health(amount: float):
    health -= amount
    if health <= 0:
        destroy()

func destroy():
    if particles_on_destruction:
        var particles = particles_on_destruction.instantiate() as OwenOneShotParticle
        if particles:
            get_tree().get_current_scene().add_child(particles)
            particles.global_position = global_position

    if root_node:
        root_node.queue_free()
    else:
        queue_free()
