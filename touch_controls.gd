class_name TouchControls
extends Control

# Touch joystick area
@onready var joystick_base = $JoystickBase
@onready var joystick_handle = $JoystickHandle
@onready var attack_button = $AttackButton
@onready var jump_button = $JumpButton
@onready var menu_button = $MenuButton

# State
var joystick_origin = Vector2.ZERO
var joystick_distance = 0.0
var is_touching = false

func _ready():
    $JoystickBase.visible = true
    $AttackButton.visible = true
    $JumpButton.visible = true
    $MenuButton.visible = true
    joystick_origin = $JoystickBase.global_position
    $Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
    setup_touch_signals()

func setup_touch_signals():
    $JoystickBase.input_event.connect(_on_joystick_input)
    $AttackButton.pressed.connect(_on_attack_pressed)
    $JumpButton.pressed.connect(_on_jump_pressed)
    $MenuButton.pressed.connect(_on_menu_pressed)

func _on_joystick_input(node, event, shape_idx):
    if event is InputEventScreenTouch and event.pressed:
        is_touching = true
        joystick_handle.global_position = event.position - joystick_origin
    elif event is InputEventScreenDrag and is_touching:
        joystick_handle.global_position = event.position - joystick_origin
    elif event is InputEventScreenTouch and not event.pressed:
        is_touching = false
        joystick_handle.global_position = Vector2.ZERO
        $Player.velocity.x = 0

func _on_attack_pressed():
    $Player.start_attack()

func _on_jump_pressed():
    if $Player.is_on_floor:
        $Player.velocity.y = -$Player.JUMP_SPEED

func _on_menu_pressed():
    get_tree().paused = not get_tree().paused
    $MenuButton.text = get_tree().paused ? "Resume" : "Menu"

func _process(delta):
    # Convert joystick position to player velocity
    if joystick_handle.global_position.length() > 0:
        var direction = joystick_handle.global_position.normalized()
        $Player.velocity.x = direction.x * 200
        
        # Update joystick visual
        var max_distance = 50
        joystick_handle.scale = Vector2(
            clamp(joystick_handle.global_position.length() / max_distance, 0, 1),
            clamp(joystick_handle.global_position.length() / max_distance, 0, 1)
        )
    else:
        $Player.velocity.x = 0
        joystick_handle.scale = Vector2(0, 0)

func show():
    visible = true
    $Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func hide():
    visible = false