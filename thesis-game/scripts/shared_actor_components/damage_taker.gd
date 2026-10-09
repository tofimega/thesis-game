@tool
class_name DamageTaker
extends Area2D

signal hit(from: Vector2)
signal hit_blocked(from: Vector2)
signal iframes_over

@export var invincible_time: float = 0
@export var invincibility_timer: Timer = null
@export var allow_areas: bool = true
@export var allow_bodies: bool = true
@export_group("Direction")
@export var directional_exlucions: Array[Vector2]
@export var direction_source: Direction
@export var draw_color: Color = Color(1, 0, 0, .3)
@export var draw_radius: float = 8

var damage_sources: int = 0

var hit_taken: bool

var _draw_shape: bool = true

func reset()->void:
    hit_taken = false
    damage_sources = 0

func _ready() -> void:
    await get_tree().process_frame
    if !Engine.is_editor_hint() and !OS.is_debug_build():
        _draw_shape = false
        queue_redraw()
        set_process(false)
    if allow_areas:
        area_entered.connect(_handle_hit)
        area_exited.connect(source_out)
    if allow_bodies:
        body_entered.connect(_handle_hit)
        body_exited.connect(source_out)
    if invincibility_timer: invincibility_timer.timeout.connect(iframes_over.emit)


func _process(_delta: float) -> void:
    queue_redraw()


func source_out(_b: Node2D) -> void:
    damage_sources -= 1
    if damage_sources < 0: damage_sources = 0
    if hit_taken and damage_sources == 0:
        if invincibility_timer: invincibility_timer.start(invincible_time)
        hit_taken = false


func _draw() -> void:
    if !_draw_shape: return
    if !Engine.is_editor_hint() and !OS.is_debug_build(): return
    for v: Vector2 in directional_exlucions:
        var x: float = deg_to_rad(v.x)
        var y: float = deg_to_rad(v.y)
        var direction_offset: float = direction_source.get_vector().angle() if direction_source else 0.0
        x += direction_offset
        draw_ellipse_arc(Vector2.ZERO, draw_radius, draw_radius, x - y, x + y, 100, draw_color, draw_radius * 2)


func _handle_hit(other: Node2D) -> void:
    if invincibility_timer and !invincibility_timer.is_stopped():
        return
    var incoming_pos: Vector2 = other.global_position
    var angle_vec: Vector2 = global_position.direction_to(incoming_pos)
    for v: Vector2 in directional_exlucions:
        var x: float = deg_to_rad(v.x)
        var y: float = deg_to_rad(v.y)
        var direction_offset: float = direction_source.get_vector().angle() if direction_source else 0.0
        x += direction_offset
        if angle_vec.angle() >= x - y and angle_vec.angle() <= x + y:
            hit_blocked.emit(angle_vec)
            return
    if damage_sources > 0:
        hit_taken = true
    elif invincibility_timer: invincibility_timer.start(invincible_time)

    hit.emit(angle_vec)
