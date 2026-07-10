class_name GameScene
extends Node2D

@export var level_map: LevelMap

var _level_index: int = -1
var _current_level: Level = null

@onready var _player: Player = $Player
@onready var _level_holder: Node2D = $LevelHolder


@warning_ignore("shadowed_variable")
func initialize_game(level_index: int, level_map: LevelMap = null) -> void:
    if level_map != null: self.level_map = level_map
    load_level(level_index)
    #TODO: animation, spawn_player
    var spawn_point: Vector2 = _current_level.load_next_room().global_position
    _player.global_position = spawn_point


func load_level(index: int) -> void:
    assert(level_map.map.size() > index)
    _level_index = index
    clear_level()
    var level_scene: PackedScene = load(level_map.map[_level_index])
    assert(level_scene.can_instantiate())
    _current_level = level_scene.instantiate()
    _level_holder.add_child(_current_level)
    
func clear_level()->void:
    for n: Node in _level_holder.get_children():
        n.queue_free()
