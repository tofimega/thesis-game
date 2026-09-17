class_name GameScene
extends Node2D

@export var level_map: LevelMap
@export var camera_scroll_speed: float = 100

var _level_index: int = -1
var _current_level: Level = null

@onready var camera_2d: Camera2D = $Camera2D
@onready var carry_controller: CarryController = $CarryController

@onready var _player: Player = %Player
@onready var _level_holder: Node2D = $LevelHolder


func _ready() -> void:
    if !OS.is_debug_build(): set_process(false)


func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("ui_cancel"):
        _current_level.unload_room()
        next_room()


@warning_ignore("shadowed_variable")
func initialize_game(level_index: int, level_map: LevelMap = null) -> void:
    if level_map != null: self.level_map = level_map
    _level_index=level_index-1
    start_level()


func load_level(index: int) -> void:
    assert(level_map.map.size() > index)
    _level_index = index
    clear_level()
    var level_scene: PackedScene = load(level_map.map[_level_index])
    assert(level_scene.can_instantiate())
    _current_level = level_scene.instantiate()
    _level_holder.add_child(_current_level)
    _current_level.room_over.connect(next_room)
    _current_level.level_clear.connect(next_level)
    Overlay.info_text.set_scrolling_text("Level "+str(_level_index+1))


func clear_level() -> void:
    for n: Node in _level_holder.get_children():
        n.queue_free()


func next_room() -> void:
    carry_controller.stop()
    # move camera to next room   
    var room_pos: float = (_current_level._room_index + 1) * -176

    await create_tween().tween_property(camera_2d, "position", Vector2(0, room_pos), abs(room_pos - camera_2d.position.y) / camera_scroll_speed).finished
    #load next room
    var spawn_point: Vector2 = _current_level.load_next_room().global_position
    # spawn player
    _player.global_position = spawn_point
    carry_controller.start()


func next_level() -> void:
    SaveGame.update_flag(level_map.clear_flags[_level_index], 1)
    SaveGame.save_game()
    if level_map.map.size() > _level_index + 1:
        start_level()
    else: game_end_sequence()


func game_end_sequence() -> void:
    SceneControl.back_to_menu(MenuScene.MenuPanel.TITLE)


func start_level()->void:
    load_level(_level_index + 1)
    camera_2d.position = Vector2.ZERO
    next_room()
