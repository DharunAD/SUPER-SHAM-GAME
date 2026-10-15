class_name Boss
extends Enemy

const BOSS_HEALTH = 300
const BOSS_ATTACK_COOLDOWN = 2.0
const BOSS_SPEED = 50.0
const PHASE_2_HEALTH = 150

# Boss specific states
var phase = 1
var fireball_timer = 0.0
var breath_cooldown = 0.0

# Override enemy ready
func _ready():
    health = BOSS_HEALTH
    sprite = $Sprite
    setup_boss_animations()

func setup_boss_animations():
    var anim_player = $AnimationPlayer
    # Add boss-specific animations
    for anim in ["idle", "run", "attack", "die", "phase2", "breath", "fireball"]:
        if not anim_player.has_animation(anim):
            anim_player.add_animation(anim)

func take_damage(amount):
    health -= amount
    health = max(0, health)
    # Flash red on hit
    $Sprite.modulate = Color.RED
    set_modulate_delay(0.1)
    if health <= 0:
        die()

func set_modulate_delay(delay):
    # Simple fade back to normal
    pass

func die():
    $AnimationPlayer.play(ANIM_DIE)
    $AnimationPlayer.animation_finished.connect(_on_die_finished)
    $Collision2D.disabled = true

func _on_die_finished():
    # Sabari vanishes, game moves to ending
    queue_free()
    emit_game_over("victory")

func update_phase():
    if health <= PHASE_2_HEALTH and phase == 1:
        phase = 2
        $AnimationPlayer.play("phase2")
        # Increase speed and new attacks
        BOSS_SPEED = 80.0
        fireball_timer = 0.0

func _physics_process(delta):
    update_phase()
    
    if is_attacking:
        attack_timer -= delta
        if attack_timer <= 0:
            is_attacking = false
            $AnimationPlayer.play(ANIM_IDLE)
    
    if not is_attacking:
        handle_ai(delta)
        handle_animations(delta)
    
    if not is_on_floor:
        velocity.y += 980.0 * delta
    
    move_and_collide(velocity * delta)
    
    is_on_floor = false
    if ray_cast.is_colliding():
        is_on_floor = true
        if velocity.y > 0:
            velocity.y = 0

func handle_ai(delta):
    # Phase 1: Simple patrol + fireballs
    if phase == 1:
        # Patrol
        velocity.x = -BOSS_SPEED * facing_direction()
        # Shoot fireballs occasionally
        fireball_timer -= delta
        if fireball_timer <= 0:
            shoot_fireball()
            fireball_timer = 2.0
    
    # Phase 2: More aggressive
    elif phase == 2:
        # Chase player if near, otherwise patrol
        var player = get_tree().get_first_node_in_group("player")
        if player:
            var to_player = player.global_position - global_position
            if abs(to_player.x) < 400:
                velocity.x = BOSS_SPEED * sgn(to_player.x)
            else:
                velocity.x = -BOSS_SPEED * facing_direction()
        else:
            velocity.x = -BOSS_SPEED * facing_direction()
        
        # Breath attack
        breath_cooldown -= delta
        if breath_cooldown <= 0:
            breath_attack()
            breath_cooldown = 3.0
    
    # Apply gravity
    if not is_on_floor:
        velocity.y += 980.0 * delta
    
    # Move and check floor
    is_on_floor = false
    if ray_cast.is_colliding():
        is_on_floor = true
        if velocity.y > 0:
            velocity.y = 0

func facing_direction() -> int:
    if global_position.x > get_parent().target_position.x:
        return -1
    return 1

func sgn(val: float) -> int:
    if val > 0: return 1
    if val < 0: return -1
    return 0

func shoot_fireball():
    var fireball = $FireballScene.instantiate()
    add_child(fireball)
    var dir = global_position.direction_to(get_parent().global_position("player"))
    fireball.position = global_position + Vector2(0, -50)
    fireball.velocity = dir * 500

func breath_attack():
    $AnimationPlayer.play("breath")
    # Create damaging area
    var breath_area = $BreathArea.instance()
    add_child(breath_area)
    breath_area.position = global_position
    $AttackHitbox.visible = true
    breath_cooldown = 5.0

func on_body_entered(body):
    if body.is_in_group("player"):
        take_damage(DAMAGE_PLAYER)