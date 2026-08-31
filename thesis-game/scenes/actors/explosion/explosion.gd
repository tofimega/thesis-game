class_name Explosion
extends Area2D

@onready var timer: Timer = $Timer


func spawn(pos: Vector2) -> void:
    global_position = pos
    visible = true
    set_deferred("monitorable", true)
    timer.start()


func stop() -> void:
    visible = false
    set_deferred("monitorable", false)


func _on_timer_timeout() -> void:
    stop()
