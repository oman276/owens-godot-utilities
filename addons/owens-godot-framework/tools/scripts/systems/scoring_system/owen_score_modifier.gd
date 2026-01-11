extends RefCounted
class_name OwenScoreModifier

# OwenScoreModifier
# A simple score modifier to apply changes to the player's score.
# version 1.0.0
# last updated: 2026-01-11

enum modifier_type {
    ADD,
    SUBTRACT,
    MULTIPLY,
    DIVIDE
}

## The type of score modification to apply.
@export var type: modifier_type = modifier_type.ADD

## The amount to modify the score by.
@export var modifier_value: int = 100

## Applies the score modification to the given score.
func apply_modifier(current_score: int) -> int:
    match type:
        modifier_type.ADD:
            return current_score + modifier_value
        modifier_type.SUBTRACT:
            return current_score - modifier_value
        modifier_type.MULTIPLY:
            return current_score * modifier_value
        modifier_type.DIVIDE:
            if modifier_value != 0:
                return current_score / modifier_value
            else:
                push_warning("OwenScoreModifier: Division by zero in score modifier.")
                return current_score
    return current_score