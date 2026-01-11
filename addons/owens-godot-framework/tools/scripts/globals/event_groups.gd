extends Node
class_name OwenEventGroups

# OwenEventGroups
# A static class for managing event group strings.
# version 1.0.0
# last updated: 2025-12-30

# We use event groups to allow decentralized signal connections to the same event.

class DamageListener:
    static var GROUP_NAME: String:
        get: return "damage_listener"
    
    static var EVENT_DESTROYED: String:
        get: return "event_destroyed"
