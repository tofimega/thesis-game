extends Node

const MENU: String = "uid://bme4yofn800lr"
const GAME: String = "uid://6px8hpqxwfe2"

const START_SCENE_UID: String = MENU

var current_scene: Node = null
var loaded_file: String

@onready var game_view: SubViewport = $GameView
@onready var game_raw: SubViewport = $GameRaw
@onready var info_text: SubViewport = $InfoText
@onready var text_raw: SubViewport = $TextRaw

@onready var label: ScrollingLabel = $TextRaw/ColorRect/Label


func _ready() -> void:
    back_to_menu(MenuScene.MenuPanel.TITLE)


func _input(event: InputEvent) -> void:
    if !event.is_action_type():
        return
    game_raw.push_input(event)


func begin_game(level_index: int, level_map: LevelMap = null) -> void:
    await _scene_switch(GAME)
    var game_scene: GameScene = current_scene
    game_scene.initialize_game(level_index, level_map)


func back_to_menu(panel: MenuScene.MenuPanel = MenuScene.MenuPanel.LEVEL_SCELECT) -> void:
    await _scene_switch(MENU)
    var menu_scene: MenuScene = current_scene
    menu_scene.switch_panel(panel)


func _scene_switch(new: String) -> void:
    var new_scene: PackedScene = load(new)
    if !new_scene.can_instantiate():
        push_error("scene could not be instantiated")
        return
    if current_scene != null: current_scene.queue_free()
    await get_tree().process_frame
    var root: Node = new_scene.instantiate()
    #TODO: fade out
    game_raw.add_child(root)
    current_scene = root
    loaded_file = new
    #TODO: fade in
