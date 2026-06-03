extends Submenu


func _input(event: InputEvent) -> void:
    print("input!")
    if !event.is_action_type():
        return
    if Input.is_action_just_pressed_by_event("ui_accept", event):
        switch_to.emit(MenuScene.MenuPanel.FILE_SELECT)
