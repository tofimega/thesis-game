extends SubViewport

const MENU: String = "uid://bme4yofn800lr"
const GAME: String = "uid://6px8hpqxwfe2"

const START_SCENE_UID: String = MENU


func _ready() -> void:
    if name != "SceneControl":
        queue_free()
        return

    var starting_scene: PackedScene = load(START_SCENE_UID)
    Overlay.set_viewport(get_texture())
    if starting_scene == null or !starting_scene.can_instantiate():
        push_error("Cannot load starting scene")
        return
    add_child(starting_scene.instantiate())
