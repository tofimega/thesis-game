class_name GameScene
extends Node2D

@export var level_map: LevelMap

var _level_index: int = -1
var _current_level: Level = null


func load_level(index: int)->void:
    assert(level_map.map.size() > index)
    _level_index = index
    var level_scene: PackedScene = load(level_map.map[_level_index])
    assert(level_scene.can_instantiate())
    _current_level = level_scene.instantiate()
    add_child(_current_level)
