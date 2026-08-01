class_name DamageTaker
extends Area2D

signal hit(from: Vector2)
signal iframes_over

@export var invincible_time: float = 0
@export var invincibility_timer: Timer = null


func _ready() -> void:

    await get_tree().process_frame

    area_entered.connect(_handle_hit)
    body_entered.connect(_handle_hit)
    invincibility_timer.timeout.connect(iframes_over.emit)


func _handle_hit(other: Node2D) -> void:
    if !invincibility_timer.is_stopped(): return
    hit.emit(other.global_position - global_position)
    invincibility_timer.start(invincible_time)
