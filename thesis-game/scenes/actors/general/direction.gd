class_name Direction
extends Node

enum Dir {
    LEFT = 0,
    RIGHT,
    UP,
    DOWN,
}

@export var face_direction: Dir = Dir.DOWN


func get_vector() -> Vector2:
    match face_direction:
        Dir.UP: return Vector2.UP
        Dir.DOWN: return Vector2.DOWN
        Dir.LEFT: return Vector2.LEFT
        Dir.RIGHT: return Vector2.RIGHT
        _: return Vector2.ZERO


func set_dir_from_vector(vec: Vector2) -> Dir:
    var longest_axis: Vector2.Axis = vec.abs().max_axis_index() as Vector2.Axis
    var s: int = sign(vec[longest_axis])
    if s == 0: return face_direction
    s = min(s, 0)
    face_direction = (longest_axis * 2 + s) as Dir

    return face_direction
