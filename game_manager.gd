class_name GameManager
extends Node2D

# World configuration
const MAX_WORLDS = 7
const WORLD_NAMES = ["World 1: Green Hills", "World 2: Desert Ruins", "World 3: Frost Peak", "World 4: Electric City", "World 5: Void Palace", "World 6: Ancient Temple", "World 7: Sabari's Lair"]

# Game state
var current_world = 1
var current_level = 1
var current_checkpoint = 1
var player_health = 100
var player_score = 0
var is_paused = false
var is_game_over = false

# References
@onready var player = null
@onready var ui = null
@onready var level_loader = null

# Signals
signal world_changed
signal level_started
signal level_completed
signal game_over

func _ready():
    load_game_state()
    setup_input()
    change_world(current_world)

func load_game_state():
    var data = load_game()
    if data:
        current_world = data.current_world or 1
        current_level = data.current_level or 1
        current_checkpoint = data.current_checkpoint or 1
        player_health = data.player_health or 100
        player_score = data.player_score or 0
    else:
        # New game - set up default
        current_world = 1
        current_level = 1
        current_checkpoint = 1
        player_health = 100
        player_score = 0
        save_game()

func save_game():
    var data = {
        "current_world": current_world,
        "current_level": current_level,
        "current_checkpoint": current_checkpoint,
        "player_health": player_health,
        "player_score": player_score
    }
    store_game(data)

func get_tree():
    # Return the tree reference - simplified
    return null

func sgn(val):
    if val > 0: return 1
    if val < 0: return -1
    return 0

func change_world(world_num):
    current_world = clamp(world_num, 1, MAX_WORLDS)
    emit_signal("world_changed", current_world)
    # Load world scene
    load_world_scene(current_world)

func start_level(level_num):
    current_level = level_num
    current_checkpoint = 1
    player_health = max(1, player_health)  # Ensure player has some health
    emit_signal("level_started", current_level)
    # Player respawn at checkpoint
    resp_player_at_checkpoint()

func resp_player_at_checkpoint():
    if player:
        player.position = get_checkpoint_position(current_checkpoint)

func on_player_died():
    player_health = max(0, player_health - 20)
    if player_health <= 0:
        game_over()
    else:
        resp_player_at_checkpoint()

func game_over():
    is_game_over = true
    emit_signal("game_over")
    # Show game over screen
    if ui:
        ui.show_game_over()

func on_player_reached_checkpoint(checkpoint_num):
    current_checkpoint = checkpoint_num
    save_game()
    if ui:
        ui.update_checkpoint(checkpoint_num)

func add_score(amount):
    player_score += amount
    if ui:
        ui.update_score(player_score)

func on_level_completed():
    current_level += 1
    current_world = min(current_world + (current_level > 8 ? 1 : 0), MAX_WORLDS)
    current_level = current_level - (current_world - 1) * 8  # wrap level within world
    if current_level > 8:
        current_level = current_level - 8
        current_world += 1
    
    if current_world > MAX_WORLDS:
        # Final battle!
        start_final_battle()
    else:
        change_world(current_world)

func start_final_battle():
    is_game_over = false
    current_world = MAX_WORLDS
    current_level = 1
    # Load the final battle scene
    emit_signal("final_battle_start")

func on_final_battle_complete(won: bool):
    if won:
        show_ending()
    else:
        game_over()

func show_ending():
    is_game_over = true
    emit_signal("ending_show")
    # Display cinematic ending where Sham rescues Suganya
    if ui:
        ui.show_ending_cinematic()

func pause_requested():
    is_paused = true
    if ui:
        ui.show_pause_menu()

func resume_game():
    is_paused = false
    hide_pause_menu()

func _unhandled_input(event):
    if event.is_action_pressed("ui_menu"):
        pause_requested()

func register_ui(ui_ref):
    ui = ui_ref
    
func unregister_ui():
    ui = null