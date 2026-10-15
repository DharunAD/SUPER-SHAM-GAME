class_name EnemySpawner
extends Area2D

# Enemy configuration
enum EnemyType { SLIME, GOBLIN, MUMMY, SCORPION, YETI, ICE_WIZARD, ROBOT, LASER_BOT, SHADOW, VOID_WALKER, DEMON, SABARI_MINION }

# Groups
enum Group { ENEMY, BOSS }

# References
@onready var level_scene = $LevelScene
@onready var player = $Player

# Spawn settings
var current_difficulty = 1.0
var enemy_count = 0
var total_enemies_to_spawn = 0
var boss_fight = false
var enemies_remaining = 0

# World-specific enemy pools
var enemy_pools = {
    1: [EnemyType.SLIME, EnemyType.GOBlin],
    2: [EnemyType.MUMMY, EnemyType.SCORPION],
    3: [EnemyType.YETI, EnemyType.ICE_WIZARD],
    4: [EnemyType.ROBOT, EnemyType.LASER_BOT],
    5: [EnemyType.SHADOW, EnemyType.VOID_WALKER],
    6: [EnemyType.MUMMY, EnemyType.SKELETON_WARRIOR],
    7: [EnemyType.DEMON, EnemyType.SABARI_MINION]
}

func _ready():
    enemy_count = 0
    enemies_remaining = 0
    boss_fight = false
    get_node("/root/GameManager").register_spawner(self)

func spawn_enemies(level_num: int):
    var pool = enemy_pools[get_tree().get_first_node_in_group("world").current_world]
    total_enemies_to_spawn = 5 + (level_num - 1) * 2  # More enemies per world
    current_difficulty = 1.0 + (level_num - 1) * 0.2
    spawn_next_enemy()

func spawn_next_enemy():
    if enemy_count >= total_enemies_to_spawn:
        check_spawn_complete()
        return
    
    # Choose random enemy type from pool
    var pool = enemy_pools[get_tree().get_first_node_in_group("world").current_world]
    var enemy_type = pool.rand()
    
    # Create enemy scene
    var enemy_scene = get_enemy_scene(enemy_type)
    var enemy = enemy_scene.instance()
    add_child(enemy)
    
    # Position enemy randomly or at patrol points
    enemy.position = Vector2(
        randf() * 800 + 100,
        randf() * 600 + 100
    )
    
    # Scale based on difficulty
    var scale = current_difficulty * randf(0.8, 1.2)
    enemy.scale = Vector2(scale, scale)
    
    enemy_count += 1
    enemies_remaining += 1
    yield(get_tree(), "process_frame")
    spawn_next_enemy()

func get_enemy_scene(enemy_type: EnemyType) -> PackedScene:
    var path = ""
    match enemy_type:
        EnemyType.SLIME: path = "res://scenes/enemies/slime.tscn"
        EnemyType.GOBlin: path = "res://scenes/enemies/goblin.tscn"
        EnemyType.MUMMY: path = "res://scenes/enemies/mummy.tscn"
        EnemyType.SCORPION: path = "res://scenes/enemies/scorpion.tscn"
        EnemyType.YETI: path = "res://scenes/enemies/yeti.tscn"
        EnemyType.ICE_WIZARD: path = "res://scenes/enemies/ice_wizard.tscn"
        EnemyType.ROBOT: path = "res://scenes/enemies/robot.tscn"
        EnemyType.LASER_BOT: path = "res://scenes/enemies/laser_bot.tscn"
        EnemyType.SHADOW: path = "res://scenes/enemies/shadow.tscn"
        EnemyType.VOID_WALKER: path = "res://scenes/enemies/void_walker.tscn"
        EnemyType.DEMON: path = "res://scenes/enemies/demon.tscn"
        EnemyType.SABARI_MINION: path = "res://scenes/enemies/sabari_minion.tscn"
    
    return preload(path)

func check_spawn_complete():
    enemies_remaining = 0
    var all_enemies = get_tree().get_nodes_in_group("enemy")
    for enemy in all_enemies:
        enemies_remaining += 1
    
    if enemies_remaining == 0 and boss_fight:
        # All regular enemies dead, start boss
        start_boss_fight()
    elif enemies_remaining == 0:
        # Level complete
        get_tree().call_deferred("_on_level_complete")

func start_boss_fight():
    boss_fight = true
    var boss_scene = preload("res://scenes/boss.tscn")
    var boss = boss_scene.instance()
    add_child(boss)
    boss.position = Vector2(400, 300)
    boss.faction = "sabari"
    $AnimationPlayer.play("boss_appear")