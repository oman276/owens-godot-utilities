extends RefCounted
class_name OwenScoreManager

# OwenScoreManager
# A simple scoring system manager to track and update player scores.
# version 1.0.0
# last updated: 2026-01-11

## The current player score.
var current_score: int = 0

## When we update the score, we can apply all active score modifiers.
var score_modifiers : Array[OwenScoreModifier] = []

## Adds a score modifier to the list.
func add_score_modifier(modifier: OwenScoreModifier) -> void:
    score_modifiers.append(modifier)

## Remove a score modifier from the list.
func remove_score_modifier(modifier : OwenScoreModifier) -> void:
    score_modifiers.erase(modifier)

## Removes all score modifiers from the list.
func clear_score_modifiers() -> void:
    score_modifiers.clear()

## Updates the current score 
func add_score(to_add: int, use_modifiers: bool = true) -> void:
    var modified_score = to_add
    if use_modifiers:
        for modifier in score_modifiers:
            modified_score = modifier.apply_modifier(modified_score)
    current_score += modified_score