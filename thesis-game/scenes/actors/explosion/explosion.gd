class_name Explosion
extends Area2D


@onready var timer: Timer = $Timer


func spawn(pos: Vector2)->void:
    global_position = pos
    visible = true
    set_collision_layer_value(5, true)
    timer.start()


func _on_timer_timeout() -> void:
    visible = false
    set_collision_layer_value(5, false)
