class_name Enemy
extends Area2D

const SPEED = 100.0
const PATROL_RANGE = 200
const PATROL_SPEED = 50.0
const ENEMY_HEALTH = 50
const DAMAGE_PLAYER = 20

# Animation names
const ANIM_IDLE = "idle"
const ANIM_RUN = "run"
const ANIM_ATTACK = "attack"
const ANIM_DIE = "die"

# Groups
enum Group { ENEMY, BOSS }

# State
var velocity = Vector2.ZERO
var is_on_floor = false
var is_attacking = false
var attack_timer = 0.0
var health = ENEMY_HEALTH
var patrol_direction = 1
var original_position = Vector2.ZERO
var target_position = Vector2.ZERO

# References
@onready var sprite = $Sprite
@onready var collision = $Collision2D
@onready var ray_cast = $RayCast2D
@onready var hitbox = $AttackHitbox

func _ready():
    original_position = position
    target_position = original_position + Vector2(PATROL_RANGE, 0)
    collision.mask = 1
    ray_cast.enabled = true
    health = ENEMY_HEALTH
    setup_animations()
    
func setup_animations():
    var anim_player = $AnimationPlayer
    if anim_player.has_animation(ANIM_IDLE):
        pass
    if not anim_player.has_animation(ANIM_IDLE):
        anim_player.add_animation(ANIM_IDLE)
    if not anim_player.has_animation(ANIM_RUN):
        anim_player.add_animation(ANIM_RUN)
    if not anim_player.has_animation(ANIM_ATTACK):
        anim_player.add_animation(ANIM_ATTACK)
    if not anim_player.has_animation(ANIM_DIE):
        anim_player.add_animation(ANIM_DIE)

func take_damage(amount):
    health -= amount
    health = max(0, health)
    if health <= 0:
        die()

func die():
    $AnimationPlayer.play(ANIM_DIE)
    $Collision2D.disabled = true
    $RayCast2D.disabled = true
    $AttackHitbox.set_deployed(false)
    queue_free()

func _physics_process(delta):
    if is_attacking:
        attack_timer -= delta
        if attack_timer <= 0:
            is_attacking = false
            $AnimationPlayer.play(ANIM_IDLE)
    
    if not is_attacking:
        handle_patrol(delta)
        handle_animations(delta)
    
    if not is_on_floor:
        velocity.y += 980.0 * delta
    
    move_and_collide(velocity * delta)
    
    is_on_floor = false
    if ray_cast.is_colliding():
        is_on_floor = true
        if velocity.y > 0:
            velocity.y = 0

func handle_patrol(delta):
    # Patrol back and forth
    if facing_right:
        velocity.x = PATROL_SPEED
    else:
        velocity.x = -PATROL_SPEED
    
    # Turn around at patrol range
    if global_position.x >= target_position.x and patrol_direction == 1:
        patrol_direction = -1
        facing_right = false
        flip_x = true
    elif global_position.x <= original_position.x and patrol_direction == -1:
        patrol_direction = 1
        facing_right = true
        flip_x = false

func attack_player(player):
    is_attacking = true
    attack_timer = 0.5
    $AnimationPlayer.play(ANIM_ATTACK)
    $AttackHitbox.visible = true

func handle_animations(delta):
    if is_on_floor:
        if velocity.x != 0:
            $AnimationPlayer.play(ANIM_RUN)
        else:
            $AnimationPlayer.play(ANIM_IDLE)
    else:
        $AnimationPlayer.play(ANIM_JUMP)

func on_body_entered(body):
    if body.has_method("take_damage") and body.is_in_group("player"):
        attack_player(body)