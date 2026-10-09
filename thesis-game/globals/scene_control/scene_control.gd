extends Node

const MENU: String = "uid://bme4yofn800lr"
const GAME: String = "uid://6px8hpqxwfe2"

const START_SCENE_UID: String = MENU

var current_scene: Node = null
var loaded_scene_path: String
@onready var loading_screen: ColorRect = $GameRaw/CanvasLayer/LoadingScreen

@onready var game_view: SubViewport = $GameView
@onready var game_raw: SubViewport = $GameRaw
@onready var info_text: SubViewport = $InfoText
@onready var text_raw: SubViewport = $TextRaw
@onready var health_raw: SubViewport = $HealthRaw
@onready var health_sprite: HealthSprite = $HealthRaw/ColorRect/HealthSprite
@onready var label: ScrollingLabel = $TextRaw/ColorRect/Label
@onready var health_display: SubViewport = $HealthDisplay


func fade_loading(alpha: float, time: float = 1)->void:
    await create_tween().tween_property(loading_screen, "color:a", alpha, time).finished


func _ready() -> void:
    fade_loading(0, 0)
    back_to_menu(MenuScene.MenuPanel.TITLE, false)


func _input(event: InputEvent) -> void:
    if event is InputEventMouse || !event.is_action_type():
        return
    game_raw.push_input(event)


func begin_game(level_index: int, level_map: LevelMap = null, fade: bool = true) -> void:
    await _scene_switch(GAME, fade)
    var game_scene: GameScene = current_scene
    game_scene.initialize_game(level_index, level_map)
    if fade: fade_loading(0, .3)


func back_to_menu(panel: MenuScene.MenuPanel = MenuScene.MenuPanel.LEVEL_SCELECT, fade: bool = true) -> void:
    await _scene_switch(MENU, fade)
    var menu_scene: MenuScene = current_scene
    menu_scene.switch_panel(panel)
    if fade: fade_loading(0, .3)


func _scene_switch(new: String, fade: bool=true) -> void:
    if fade: await fade_loading(1, .3)
    var new_scene: PackedScene = load(new)
    if !new_scene.can_instantiate():
        push_error("scene could not be instantiated")
        return
    if current_scene != null: current_scene.queue_free()
    await get_tree().process_frame
    var root: Node = new_scene.instantiate()
    #TODO: fade out
    game_raw.add_child(root)
    loading_screen.move_to_front()
    current_scene = root
    loaded_scene_path = new
    #TODO: fade in
