extends Submenu # file select


func _input(event: InputEvent) -> void:
    if Input.is_action_just_pressed_by_event("ui_cancel", event):
        switch_to.emit(MenuScene.MenuPanel.TITLE)


func on_show() -> void:
    Overlay.info_text.set_scrolling_text("Load which file?")


func on_hide() -> void:
    pass
