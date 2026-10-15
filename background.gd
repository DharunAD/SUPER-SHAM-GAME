class_name Background
extends Node2D

# World themes
const THEMES = {
    1: {"name": "green_hills", "color": Color(0.2, 0.6, 0.2), "tileset": "tileset_grass"},
    2: {"name": "desert_ruins", "color": Color(0.8, 0.6, 0.2), "tileset": "tileset_desert"},
    3: {"name": "frost_peak", "color": Color(0.3, 0.5, 0.8), "tileset": "tileset_ice"},
    4: {"name": "electric_city", "color": Color(0.3, 0.3, 0.4), "tileset": "tileset_city"},
    5: {"name": "void_palace", "color": Color(0.1, 0.1, 0.2), "tileset": "tileset_void"},
    6: {"name": "ancient_temple", "color": Color(0.5, 0.3, 0.1), "tileset": "tileset_temple"},
    7: {"name": "sabaris_lair", "color": Color(0.4, 0.1, 0.2), "tileset": "tileset_lair"}
}

var current_world = 1
var modulate_color = Color.WHITE

func _ready():
    modulate()

func set_world(world_num: int):
    current_world = clamp(world_num, 1, 7)
    modulate_color = THEMES[current_world].color
    modulate(modulate_color)

func modulate():
    modulate_color = THEMES[current_world].color
    modulate(modulate_color)

func _process(delta):
    # Parallax scrolling effect
    pass