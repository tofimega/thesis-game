extends Control

@export var default_powerup_texture: Texture

var fullscreen: bool = false

@onready var loading: TextureRect = $Loading

@onready var viewport: TextureRect = $HBoxContainer/Viewport
@onready var info_text: ScrollingLabel = SceneControl.label
@onready var health: TextureRect = $HBoxContainer/NinePatchRect/LeftPanel/VBoxContainer/Health
@onready var powerup_icon: TextureRect = $HBoxContainer/NinePatchRect/LeftPanel/VBoxContainer/PowerupIcon

@onready var _info_text: TextureRect = $HBoxContainer/NinePatchRect/LeftPanel/VBoxContainer/InfoText


func _ready() -> void:
    viewport.texture = SceneControl.game_view.get_texture()
    _info_text.texture = SceneControl.info_text.get_texture()
    health.texture = SceneControl.health_display.get_texture()
    powerup_icon.texture = SceneControl.powerup_display.get_texture()


func _unhandled_input(event: InputEvent) -> void:
    if Input.is_action_just_pressed_by_event("toggle_fullscreen", event):
        fullscreen = !fullscreen
        DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN if fullscreen else DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)
