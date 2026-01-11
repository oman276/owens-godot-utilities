extends Node2D
class_name OwenOneShotParticle

# OwenOneShotParticle
# A simple wrapper for a one-shot particle effect which deletes itself after playing.
# version 1.0.0
# last updated: 2026-01-11

@export var particle_effect_scene: PackedScene = null

func _ready():
    print("Playing One-Shot Particle")
    if particle_effect_scene:
        var particle_effect = particle_effect_scene.instantiate() as GPUParticles2D
        if not particle_effect:
            push_error("OwenOneShotParticle: particle_effect_scene is not a GPUParticles2D.")
            return
        
        add_child(particle_effect)
        particle_effect.position = Vector2.ZERO
        particle_effect.emitting = true
        particle_effect.one_shot = true
        particle_effect.finished.connect(_on_particle_finished)
        print("OwenOneShotParticle: Particle effect spawn completed.")

    else:
        push_error("OwenOneShotParticle: No particle_effect assigned.")


func _on_particle_finished():
    print("Deleting One-Shot Particle")
    queue_free()