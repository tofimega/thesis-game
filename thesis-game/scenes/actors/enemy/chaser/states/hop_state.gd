class_name HopState
extends AnimateState

@export var height: float = 5


func process_enemy(_enemy: Enemy, _delta: float) -> void:
    if !timer_node: return
    _enemy.animated_sprite_2d.offset.y = -sin(remap(timer_node.time_left, 0, timer_node.wait_time, 0, PI)) * height


func exit_state(_enemy: Enemy) -> void:
    super(_enemy)
    _enemy.animated_sprite_2d.offset.y = 0
