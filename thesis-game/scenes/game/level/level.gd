@tool
class_name Level
extends Node2D

signal room_over
signal level_clear

@export_tool_button("Reorder Rooms") var reorder: Callable = reorder_rooms

var _current_room: Room = null
var _room_index: int = -1

@onready var _rooms: Node2D = $Rooms


func _ready() -> void:
    reorder_rooms()


func reorder_rooms() -> void:
    for i: int in _rooms.get_child_count():
        var r: Room = _rooms.get_child(i)
        r.position.y = -i * 11 * 16


func unload_room() -> void:
    if _current_room: _current_room.clear_room()


func load_next_room() -> Marker2D:
    if _current_room == null: _room_index = -1
    _room_index += 1
    if _room_index >= _rooms.get_child_count():
        _current_room = null
        return null

    _current_room = _rooms.get_child(_room_index)
    _current_room.room_cleared.connect(advance_room, CONNECT_ONE_SHOT)
    _current_room.spawn_actors()

    return _current_room.player_spawn


func advance_room() -> void:
    unload_room()
    if last_room():
        level_clear.emit()
        return
    room_over.emit()


func last_room() -> bool:
    return _room_index == _rooms.get_child_count() - 1
