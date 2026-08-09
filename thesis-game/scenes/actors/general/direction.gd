@tool
class_name Direction
extends Node

enum Dir {
    LEFT = 0,
    RIGHT,
    UP,
    DOWN,
}

@export var face_direction: Dir = Dir.DOWN


@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
func get_vector(dir: Dir = -1) -> Vector2:
    var f: Dir = face_direction if dir == -1 else dir
    match f:
        Dir.UP: return Vector2.UP
        Dir.DOWN: return Vector2.DOWN
        Dir.LEFT: return Vector2.LEFT
        Dir.RIGHT: return Vector2.RIGHT
        _: return Vector2.ZERO


func set_dir_from_vector(vec: Vector2) -> Dir:
    var a: Array[float]
    a.resize(Dir.size())
    for f: Dir in Dir.values():
        a[f] = abs(get_vector(f).angle_to(vec))
    face_direction = a.find(a.min()) as Dir
    return face_direction
