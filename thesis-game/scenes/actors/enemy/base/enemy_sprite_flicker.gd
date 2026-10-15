@tool
class_name EnemySprite
extends AnimatedSprite2D


@export var flicker: bool = false
@export var flicker_rate: float = 1
@export var flicker_length: float = .1

var _time: float = 0
var _on: bool = false

func _process(delta: float)->void:
    if !flicker:
        set_instance_shader_parameter("flicker_on", false)
        return

    _time+=delta
    if _on and _time >= flicker_length:
        _on = false
        _time = 0
    elif _time >= flicker_rate:
        _on = true
        _time = 0
    set_instance_shader_parameter("flicker_on", _on)
