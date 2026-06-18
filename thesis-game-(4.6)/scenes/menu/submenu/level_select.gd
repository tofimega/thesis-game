extends Submenu # level select


func _gui_input(event: InputEvent) -> void:
    if Input.is_action_just_pressed_by_event("ui_cancel", event):
        switch_to.emit(MenuScene.MenuPanel.FILE_SELECT)


func on_show() -> void:
    Overlay.info_text.set_scrolling_text("Select a Level")


func on_hide() -> void:
    pass
