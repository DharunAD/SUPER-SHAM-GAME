class_name Player
extends Area2D

# Player dimensions
const SPEED = 200.0
const JUMP_SPEED = 400.0
const ATTACK_COOLDOWN = 0.2
const ATTACK_RANGE = 50
const MAX_HEALTH = 100
const ATTACK_ANIMATION_SPEED = 0.1

# Animation names
const ANIM_IDLE = "idle"
const ANIM_RUN = "run"
const ANIM_JUMP = "jump"
const ANIM_ATTACK = "attack"
const ANIM_DIE = "die"

# Signals
signal hit_taken
signal died

# State
var velocity = Vector2.ZERO
var is_on_floor = false
var is_attacking = false
var attack_timer = 0.0
var health = MAX_HEALTH
var score = 0
var facing_right = true

# References
@onready var sprite = $Sprite
@onready var collision = $Collision2D
@onready var ray_cast = $RayCast2D
@onready var hitbox = $AttackHitbox

func _ready():
    collision.mask = 1  # Player collision mask
    ray_cast.enabled = true
    health = MAX_HEALTH
    score = 0
    setup_animations()
    
func setup_animations():
    var anim_player = $AnimationPlayer
    if anim_player.has_animation(ANIM_IDLE):
        pass
    # Create basic animations if they don't exist
    if not anim_player.has_animation(ANIM_IDLE):
        anim_player.add_animation(ANIM_IDLE)
    if not anim_player.has_animation(ANIM_RUN):
        anim_player.add_animation(ANIM_RUN)
    if not anim_player.has_animation(ANIM_JUMP):
        anim_player.add_animation(ANIM_JUMP)
    if not anim_player.has_animation(ANIM_ATTACK):
        anim_player.add_animation(ANIM_ATTACK)
    if not anim_player.has_animation(ANIM_DIE):
        anim_player.add_animation(ANIM_DIE)

func take_damage(amount):
    health -= amount
    health = max(0, health)
    emit_signal("hit_taken", amount)
    if health <= 0:
        die()

func die():
    $AnimationPlayer.play(ANIM_DIE)
    emit_signal("died")
    # Disable player after death
    $Collision2D.disabled = true
    velocity = Vector2.ZERO

func _physics_process(delta):
    if is_attacking:
        attack_timer -= delta
        if attack_timer <= 0:
            is_attacking = false
            $AttackHitbox.visible = false
            $AnimationPlayer.play(ANIM_IDLE)
    
    if not is_attacking:
        handle_movement(delta)
        handle_animations(delta)
    
    # Apply gravity and move
    if not is_on_floor:
        velocity.y += 980.0 * delta  # gravity
    
    move_and_collide(velocity * delta)
    
    # Check if on floor after moving
    is_on_floor = false
    if ray_cast.is_colliding():
        is_on_floor = true
        if velocity.y > 0:
            velocity.y = 0

func handle_movement(delta):
    var input_dir = Vector2.ZERO
    
    # Keyboard input
    if Input.is_action_pressed("ui_right"):
        input_dir.x += 1
    if Input.is_action_pressed("ui_left"):
        input_dir.x -= 1
    if Input.is_action_pressed("ui_up") and is_on_floor:
        velocity.y = -JUMP_SPEED
    if Input.is_action_pressed("ui_attack") and not is_attacking:
        start_attack()
    
    # Normalize direction
    if input_dir.length() > 0:
        input_dir = input_dir.normalized()
    
    # Flip sprite based on direction
    if input_dir.x > 0 and not facing_right:
        flip_x = true
        facing_right = true
    elif input_dir.x < 0 and facing_right:
        flip_x = false
        facing_right = false
    
    # Store horizontal velocity
    velocity.x = input_dir.x * SPEED

func start_attack():
    is_attacking = true
    attack_timer = ATTACK_COOLDOWN
    $AnimationPlayer.play(ANIM_ATTACK)
    $AttackHitbox.visible = true
    $AttackHitbox.position = Vector2(ATTACK_RANGE * (facing_right ? 1 : -1), 0)

func handle_animations(delta):
    if is_on_floor:
        if velocity.x != 0:
            $AnimationPlayer.play(ANIM_RUN)
        else:
            $AnimationPlayer.play(ANIM_IDLE)
    else:
        $AnimationPlayer.play(ANIM_JUMP)

func restore_health(amount):
    health = min(MAX_HEALTH, health + amount)
    return health
```