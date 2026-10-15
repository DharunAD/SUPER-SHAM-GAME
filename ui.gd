class_name UI
extends Control

# UI References
@onready var health_bar = $HealthBar
@onready var score_label = $ScoreLabel
@onready var pause_button = $PauseButton
@onready var menu_popup = $MenuPopup
@onready var resume_button = $ResumeButton
@onready var quit_button = $QuitButton
@onready var ending_cinematic = $EndingCinematic
@onready var checkpoints_label = $CheckpointsLabel

# Game state
var current_health = 100
var max_health = 100
var current_score = 0
var current_checkpoint = 1

func _ready():
    setup_signals()
    update_health_bar()
    update_score_label()
    
func setup_signals():
    $StartButton.pressed.connect(_on_start_pressed)
    $ContinueButton.pressed.connect(_on_continue_pressed)
    $NewGameButton.pressed.connect(_on_new_game_pressed)
    $PauseButton.pressed.connect(_on_pause_pressed)
    $ResumeButton.pressed.connect(_on_resume_pressed)
    $QuitButton.pressed.connect(_on_quit_pressed)
    $SettingsButton.pressed.connect(_on_settings_pressed)
    
    # Health bar signals
    $HealthBar.minus.connect(-_on_health_decreased)
    $HealthBar.plus.connect(_on_health_increased)
    
    # Checkpoint signals
    $CheckpointSignal.connect(_on_checkpoint_reached)

func _on_start_pressed():
    hide_start_menu()
    start_new_game()

func _on_continue_pressed():
    load_game()

func _on_new_game_pressed():
    reset_game()
    hide_start_menu()

func _on_pause_pressed():
    $MenuPopup.visible = true
    $Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_resume_pressed():
    $MenuPopup.visible = false
    $Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _on_quit_pressed():
    get_tree().quit()

func _on_settings_pressed():
    show_settings_menu()

func show_settings_menu():
    $SettingsPopup.visible = true

func hide_settings_menu():
    $SettingsPopup.visible = false

func update_health_bar(amount = 0):
    if amount != 0:
        current_health = max(0, min(max_health, current_health + amount))
    health_bar.value = current_health
    health_bar.text = str(current_health) + "/" + str(max_health)
    # Flash red when low
    if current_health <= 20:
        health_bar.modulate = Color.RED
    else:
        health_bar.modulate = Color.WHITE

func update_score_label(amount = 0):
    if amount != 0:
        current_score += amount
    score_label.text = "Score: " + str(current_score)

func update_checkpoint(checkpoint_num):
    current_checkpoint = checkpoint_num
    checkpoints_label.text = "Checkpoint: " + str(checkpoint_num)

func show_game_over():
    $GameOverPopup.visible = true
    $Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func hide_game_over():
    $GameOverPopup.visible = false
    $Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func show_ending_cinematic():
    $EndingCinematic.visible = true
    $Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    $AnimationPlayer.play("ending")

func hide_ending_cinematic():
    $EndingCinematic.visible = false
    $Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
    get_tree().change_scene_to_file("res://scenes/credits.tscn")