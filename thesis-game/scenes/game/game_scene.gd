class_name GameScene
extends Node2D

@export var level_map: LevelMap
@export var camera_scroll_speed: float = 100

var last_powerup: PowerupInfo = null

var _level_index: int = -1
var _current_level: Level = null

@onready var camera_2d: Camera2D = $Camera2D
@onready var carry_controller: CarryController = $CarryController
@onready var results_screen: LevelEndScreen = $Camera2D/ResultsScreen

@onready var _player: Player = %Player
@onready var _level_holder: Node2D = $LevelHolder


@warning_ignore("shadowed_variable")
func initialize_game(level_index: int, level_map: LevelMap = null) -> void:
    if level_map != null: self.level_map = level_map
    _level_index = level_index - 1
    start_level()


func load_level(index: int) -> void:
    assert(level_map.map.size() > index)
    _level_index = index
    clear_level()
    var level_scene: PackedScene = load(level_map.map[_level_index])

    #set_player_powerup(find_powerup(index))

    var unlocked_powerups: Array = level_map.unlock_power_on_clear.keys().filter(func(k: int) -> bool: return k < index)
    if !unlocked_powerups.is_empty():
        set_player_powerup(level_map.unlock_power_on_clear[unlocked_powerups.max()])

    assert(level_scene.can_instantiate())
    _current_level = level_scene.instantiate()
    _level_holder.add_child(_current_level)
    _current_level.room_over.connect(next_room)
    _current_level.level_clear.connect(next_level)
    Overlay.info_text.set_scrolling_text("Level " + str(_level_index + 1))


func find_powerup(index: int) -> PowerupInfo:
    var unlocked_powerups: Array = level_map.unlock_power_on_clear.keys().filter(func(k: int) -> bool: return k < index)
    if !unlocked_powerups.is_empty():
        var p: PowerupInfo = level_map.unlock_power_on_clear[unlocked_powerups.max()]
        if p == last_powerup:
            return null
        last_powerup = p
        return p
    return null


func set_player_powerup(powerup: PowerupInfo) -> void:
    if powerup == null: return
    _player.powerup_action = powerup.powerup
    #TODO: set overlay texture


func clear_level() -> void:
    results_screen.reset()
    for n: Node in _level_holder.get_children():
        n.queue_free()


func next_room() -> void:
    carry_controller.stop()
    # move camera to next room   
    var room_pos: float = (_current_level.room_index + 1) * -176

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
        await level_end_sequence()
        start_level()
        await SceneControl.fade_loading(0, .3)
    else: game_end_sequence()


func reset_level() -> void:
    _level_index -= 1
    start_level()


func game_end_sequence() -> void:
    SceneControl.back_to_menu(MenuScene.MenuPanel.TITLE)


func level_end_sequence() -> void:
    carry_controller.stop()
    _player.visible = true
    results_screen.fade(1, 1)
    y_sort_enabled=false
    await create_tween().set_ease(Tween.EASE_OUT).tween_property(_player, "global_position", camera_2d.get_screen_center_position(), 1).finished
    await results_screen.display_level_text(_level_index + 1)
    await get_tree().create_timer(1).timeout
    var p: PowerupInfo = find_powerup(_level_index + 1)
    if p!=null:
        set_player_powerup(p)
        await results_screen.display_powerup_text(p.powerup_name)
        await get_tree().create_timer(1).timeout
    await SceneControl.fade_loading(1, .3)
    y_sort_enabled=true
    
    #TODO: animate


func start_level() -> void:
    load_level(_level_index + 1)
    camera_2d.position = Vector2.ZERO
    next_room()


func _on_player_out() -> void:
    reset_level()
