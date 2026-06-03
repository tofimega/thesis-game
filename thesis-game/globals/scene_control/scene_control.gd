extends SubViewport

const MENU: PackedScene = preload("uid://bme4yofn800lr")
const starting_scene: PackedScene = MENU


func _ready() -> void:
    if name != "SceneControl":
        queue_free()
        return
    Overlay.set_viewport(get_texture())
    if starting_scene == null or !starting_scene.can_instantiate():
        push_error("Cannot load starting scene")
        return
    add_child(starting_scene.instantiate())
