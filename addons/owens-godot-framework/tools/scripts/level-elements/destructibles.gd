extends Node2D
class_name OwenDestructible

@export var root_node: Node2D = null
@export var initial_health: float = 100.0
@export var value_on_destruction: float = 0.0

var health: float

func _ready():
    health = initial_health

func reduce_health(amount: float):
    health -= amount
    if health <= 0:
        destroy()

func destroy():
    # Call the event group to notify any listeners that a destructible has been destroyed with a particular value.
    get_tree().call_group(OwenEventGroups.DamageListener.GROUP_NAME, 
        OwenEventGroups.DamageListener.EVENT_DESTROYED,  
        value_on_destruction)
    
    if root_node:
        root_node.queue_free()
    else:
        queue_free()
