extends Node

const MENU: String = "uid://bme4yofn800lr"
const GAME: String = "uid://6px8hpqxwfe2"

const START_SCENE_UID: String = MENU

@onready var game_view: SubViewport = $GameView
@onready var game_raw: SubViewport = $GameRaw
@onready var info_text: SubViewport = $InfoText
@onready var text_raw: SubViewport = $TextRaw

@onready var label: ScrollingLabel = $TextRaw/ColorRect/Label

func _ready() -> void:
    var starting_scene: PackedScene = load(START_SCENE_UID)
    await get_tree().process_frame
    #Overlay.set_viewport(get_texture())
    if starting_scene == null or !starting_scene.can_instantiate():
        push_error("Cannot load starting scene")
        return
    game_raw.add_child.bind(starting_scene.instantiate()).call_deferred()


func _input(event: InputEvent) -> void:
    if !event.is_action_type():
        return
    game_raw.push_input(event)
