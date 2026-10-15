class_name AttackHitbox
extends Area2D

const DAMAGE = 20
const KNOCKBACK = 300.0

func _ready():
    mask_except = [1]  # Will collide with enemies
    monitorizable = true
    connect("body_entered", _on_body_entered)

func _on_body_entered(body):
    if body.is_in_group("enemy"):
        body.take_damage(DAMAGE)
        # Apply knockback
        var dir = global_position.direction_to(body.global_position)
        body.velocity.x = -dir.x * KNOCKBACK
    elif body.is_in_group("boss"):
        body.take_damage(DAMAGE)
        # Push boss back
        var push_dir = global_position.direction_to(body.global_position)
        body.position += push_dir * 20

func _process(delta):
    # Auto-delete after attack animation
    pass