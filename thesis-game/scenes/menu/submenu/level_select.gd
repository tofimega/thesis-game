extends Submenu # level select

@export var level_map: LevelMap
@export var level_button: PackedScene
@export var level_container: Control


func _unhandled_input(event: InputEvent) -> void:
    if Input.is_action_just_pressed_by_event("ui_cancel", event):
        switch_to.emit(MenuScene.MenuPanel.FILE_SELECT)


func on_show() -> void:
    Overlay.info_text.set_scrolling_text("Select a Level")
    for c: Node in level_container.get_children(): c.queue_free()

    for l: int in level_map.map.size():
        var lb: LevelButton = level_button.instantiate()
        lb.text = "Level " + str(l + 1)
        lb.disabled = level_map.clear_flags.has(l - 1) and SaveGame.read_flag(level_map.clear_flags[l - 1]) == 0
        lb.clear = !(level_map.clear_flags.has(l) and !SaveGame.read_flag(level_map.clear_flags[l]))
        lb.pressed.connect(SceneControl.begin_game.bind(l))
        level_container.add_child(lb)

    await get_tree().process_frame
    for i: int in level_container.get_child_count():
        var c: Control = level_container.get_child(i)
        c.focus_neighbor_bottom = level_container.get_child((i + 1)%level_container.get_child_count()).get_path()
        c.focus_neighbor_top = level_container.get_child((i - 1)%level_container.get_child_count()).get_path()
        c.focus_neighbor_left = level_container.get_child(0).get_path()
        c.focus_neighbor_right = level_container.get_child(level_container.get_child_count() - 1).get_path()
    level_container.get_child(0).grab_focus.call_deferred()


func on_hide() -> void:
    pass


func _gui_input(_event: InputEvent) -> void:
    pass
