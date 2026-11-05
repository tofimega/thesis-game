class_name Targeter
extends Node2D

@export var target: Node2D:
    set = set_target

func get_direction_to_target()->Vector2:
    assert(target != null)
    return global_position.direction_to(target.global_position)

func set_target(t: Node2D)->void:
    target = t
