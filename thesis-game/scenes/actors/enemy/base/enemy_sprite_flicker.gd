@tool
class_name Flickerer
extends Node

const ENEMY_FLICKER: ShaderMaterial = preload("uid://d12bjsnchxrar")

@export var sprite: CanvasItem:
    set = set_sprite

@export var flicker: bool = false
@export var flicker_rate: float = 1
@export var flicker_length: float = .1

var _time: float = 0
var _on: bool = false


func _ready() -> void:
    await get_tree().process_frame
    set_sprite(sprite)


func _process(delta: float) -> void:
    if !has_sprite(): return
    if !flicker:
        sprite.set_instance_shader_parameter("flicker_on", false)
        return

    _time += delta
    if _on and _time >= flicker_length:
        _on = false
        _time = 0
    elif _time >= flicker_rate:
        _on = true
        _time = 0
    sprite.set_instance_shader_parameter("flicker_on", _on)


func has_sprite() -> bool:
    return sprite != null and is_instance_valid(sprite) and !sprite.is_queued_for_deletion()


func set_sprite(s: CanvasItem) -> void:
    sprite = s
    if has_sprite():
        sprite.material = ENEMY_FLICKER
