class_name LevelButton
extends Button

@export var clear_icon: Texture2D
@export var incomplete_icon: Texture2D

var clear: bool = false:
    set(c):
        icon = clear_icon if c else incomplete_icon
