extends Control

@onready var loading: TextureRect = $Loading

@onready var viewport: TextureRect = $HBoxContainer/Viewport
@onready var _info_text: TextureRect = $HBoxContainer/NinePatchRect/LeftPanel/VBoxContainer/InfoText
@onready var info_text: ScrollingLabel = SceneControl.label
@onready var health: TextureRect = $HBoxContainer/NinePatchRect/LeftPanel/VBoxContainer/Health






func _ready() -> void:
    viewport.texture = SceneControl.game_view.get_texture()
    _info_text.texture = SceneControl.info_text.get_texture()
    health.texture = SceneControl.health_display.get_texture()
