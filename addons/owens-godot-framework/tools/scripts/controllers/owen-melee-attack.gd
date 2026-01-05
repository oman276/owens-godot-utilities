extends Node2D
class_name OwenMeleeAttack

# OwenMeleeAttack
# A simple melee attack controller for 2D games.
# Detects objects within an Area2D zone and damages OwenDestructible components.
# version 1.0.0
# last updated: 2025-12-30

# ============================================================================
# SIGNALS
# ============================================================================

# ## Emitted when an attack is executed (useful for animations/sounds).
# signal attack_executed
# ## Emitted for each destructible that was hit during an attack.
# signal hit_destructible(destructible: OwenDestructible)

# ============================================================================
# EXPORTED PROPERTIES
# ============================================================================

## Amount of damage dealt per attack.
@export var damage: float = 200.0
## Time between attacks in seconds.
@export var cooldown_duration: float = 0.5
## Whether the controller should process input. Set to false to disable input controls.
@export var input_enabled: bool = true

# ============================================================================
# NODE REFERENCES
# ============================================================================

## The Area2D used to detect objects in attack range.
## Expected to have a CollisionShape2D child with the desired attack shape.
@onready var AttackZone: Area2D = $AttackZone
@onready var CooldownTimer: Timer = $CooldownTimer

func _ready() -> void:
	# Validate that the AttackZone and CooldownTimer exist
	if AttackZone == null:
		push_error("OwenMeleeAttack: AttackZone (Area2D) child node not found. Please add an Area2D named 'AttackZone' with a CollisionShape2D child.")
	if CooldownTimer == null:
		push_error("OwenMeleeAttack: CooldownTimer (Timer) child node not found. Please add a Timer named 'CooldownTimer'.")


func _process(_delta: float) -> void:
	# Skip input processing if disabled
	if not input_enabled:
		return
	
	# Check for attack input
	if Input.is_action_just_pressed(OwenInputManager.MeleeAttack.ATTACK):
		attack()

## Execute a melee attack. Can be called directly from external scripts.
## Returns true if the attack was executed, false if on cooldown.
func attack() -> bool:
	return _execute_attack()

## Returns true if the attack is ready (not on cooldown).
func is_attack_ready() -> bool:
	return CooldownTimer.is_stopped()


## Internal function that performs the attack logic.
func _execute_attack() -> bool:
	
	print("OwenMeleeAttack: Executing attack.")

	# Check cooldown
	if not is_attack_ready():
		push_warning("OwenMeleeAttack: Cannot attack - not on cooldown.")
		return false
	
	# Get all bodies currently overlapping the attack zone
	if AttackZone == null:
		push_warning("OwenMeleeAttack: Cannot attack - AttackZone is null.")
		return false
	
	var bodies = AttackZone.get_overlapping_bodies()
	print("OwenMeleeAttack: Found ", bodies.size(), " bodies overlapping the attack zone.")
	# Process each body to find destructibles
	for body in bodies:
		print("OwenMeleeAttack: Found body - ", body.name)
		var destructible = _find_destructible(body)
		if destructible != null:
			print("OwenMeleeAttack: Found destructible - reducing health by ", damage)
			destructible.reduce_health(damage)
	
	# Start cooldown
	_start_cooldown()
	
	return true

## Finds an OwenDestructible on the given node or its children.
## Returns the first OwenDestructible found, or null if none exists.
func _find_destructible(node: Node) -> OwenDestructible:
	# First check if the node itself is an OwenDestructible
	if node is OwenDestructible:
		return node
	
	# Then check all children for an OwenDestructible
	for child in node.get_children():
		var destructible = _find_destructible(child)
		if destructible != null:
			return destructible
	
	# No destructible found
	return null

## Starts the attack cooldown timer.
func _start_cooldown() -> void:
	CooldownTimer.stop()
	CooldownTimer.start(cooldown_duration)
