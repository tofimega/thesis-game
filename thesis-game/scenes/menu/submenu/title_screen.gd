extends Submenu # title screen


func _gui_input(event: InputEvent) -> void:
    if !event.is_action_type():
        return
    if Input.is_action_just_pressed_by_event("ui_accept", event):
        switch_to.emit(MenuScene.MenuPanel.FILE_SELECT)


func on_show() -> void:
    Overlay.info_text.set_scrolling_text("THESIS GAME")


func on_hide() -> void:
    pass
