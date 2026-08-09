@tool
class_name DamageTaker
extends Area2D

signal hit(from: Vector2)
signal hit_blocked(from: Vector2)
signal iframes_over

@export var invincible_time: float = 0
@export var invincibility_timer: Timer = null
@export var directional_exlucions: Array[Vector2]


func _ready() -> void:

    await get_tree().process_frame
    if !Engine.is_editor_hint(): set_process(false)
    area_entered.connect(_handle_hit)
    body_entered.connect(_handle_hit)
    invincibility_timer.timeout.connect(iframes_over.emit)


func _process(delta: float) -> void:
    queue_redraw()


func _draw() -> void:
    for v: Vector2 in directional_exlucions:
        var x: float = deg_to_rad(v.x)
        var y: float = deg_to_rad(v.y)
        draw_ellipse_arc(Vector2.ZERO, 8, 8, x - y, x + y, 100, Color(1, 0, 0, .3), 16)


func _handle_hit(other: Node2D) -> void:
    if !invincibility_timer.is_stopped(): return
    var incoming_pos: Vector2 = other.global_position
    var angle_vec: Vector2 = global_position.direction_to(incoming_pos)
    for v: Vector2 in directional_exlucions:
        var x: float = deg_to_rad(v.x)
        var y: float = deg_to_rad(v.y)
        if angle_vec.angle() >= x - y and angle_vec.angle() <= x + y:
            hit_blocked.emit(angle_vec)
            return

    hit.emit(angle_vec)
    invincibility_timer.start(invincible_time)
