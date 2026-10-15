class_name Sabari
extends Boss

# Sabari specific attributes
const SABARI_INITIAL_HEALTH = 300
const SABARI_PHASE_2_HEALTH = 150
const SABARI_ATTACK_RADIUS = 400
const SABARI_BREATH_DAMAGE = 30
const SABARI_FIREBALL_SPEED = 300.0

# Animation states
var sabari_roar_timer = 0.0
var sabari_breath_duration = 2.0

# References
@onready var beard = $Beard
@onready var cape = $Cape

func _ready():
    health = SABARI_INITIAL_HEALTH
    phase = 1
    setup_sabari_animations()
    # Initial position
    position = Vector2(400, 100)
    
func setup_sabari_animations():
    var anim_player = $AnimationPlayer
    for anim in ["idle", "run", "attack", "die", "phase2", "breath", "roar", "fireball"]:
        if not anim_player.has_animation(anim):
            anim_player.add_animation(anim)

func take_damage(amount):
    health -= amount
    health = max(0, health)
    # Visual feedback - red flash
    $Sprite.modulate = Color.RED
    $Beard.modulate = Color.RED
    set_modulate_delay(0.1)
    # Phase change
    if health <= SABARI_PHASE_2_HEALTH and phase == 1:
        phase = 2
        $AnimationPlayer.play("phase2")
        $Beard.scale = $Beard.scale * 1.2  # Beard stands up straighter
    if health <= 0:
        die()

func die():
    $AnimationPlayer.play("die")
    $Beard.visible = false
    $Cape.visible = false
    $Collision2D.disabled = true
    # Trigger ending sequence
    get_tree().call_deferred("_on_sabari_defeated")

func _on_sabari_defeated():
    # Sabari defeated - Sham rescues Suganya
    get_tree().call_deferred("show_ending")
    # Fade to ending scene
    get_tree().change_scene_to_file("res://scenes/ending.tscn")

func roar_attack():
    $AnimationPlayer.play("roar")
    # Create shockwave
    var shockwave = $ShockWave.instance()
    add_child(shockwave)
    shockwave.position = global_position
    shockwave.scale = Vector2(1, 1)
    $AttackHitbox.visible = true
    sabari_roar_timer = 3.0

func breath_attack():
    $AnimationPlayer.play("breath")
    # Create breathing area
    var breath_area = $BreathArea.instance()
    add_child(breath_area)
    breath_area.position = global_position + Vector2(0, 50)
    $AttackHitbox.visible = true
    sabari_breath_duration = 2.0

func _physics_process(delta):
    # Breath attack cooldown
    if sabari_breath_duration > 0:
        sabari_breath_duration -= delta
    
    # Roar attack cooldown
    if sabari_roar_timer > 0:
        sabari_roar_timer -= delta
    
    # Phase 2 behavior - more aggressive
    if phase == 2:
        # Faster movement
        var to_player = get_tree().get_first_node_in_group("player").global_position - global_position
        if abs(to_player.x) < SABARI_ATTACK_RADIUS:
            velocity.x = 100 * sgn(to_player.x)
        
        # More frequent breath attacks
        if sabari_breath_duration <= 0:
            breath_attack()
            sabari_breath_duration = 3.0
    
    # Call parent physics process
    super._physics_process(delta)

func sgn(val: float) -> int:
    if val > 0: return 1
    if val < 0: return -1
    return 0