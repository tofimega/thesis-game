class_name HealthSprite
extends AnimatedSprite2D

var on: bool = false:
    set = set_on
var health: int = 0:
    set = set_health


func _ready() -> void:
    animation = &"default"
    _update_texture()


func set_on(o: bool) -> void:
    on = o
    _update_texture()

func set_health(h: int) -> void:
    health = clamp(h, 0, 3)
    _update_texture()


func _update_texture() -> void:
    if on:
        modulate = Color.WHITE
        frame = health
    else:
        frame = 0
        modulate = Color.DIM_GRAY
