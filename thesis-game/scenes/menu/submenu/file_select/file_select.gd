extends Submenu # file select

@onready var file_panels: Array[FilePanel] = [
    $MarginContainer/Panel/MarginContainer/VBoxContainer/FilePanel
]

enum Mode {
    SELECT_FILE,
    COPY_FILE
}

var selected_panel: int = 0
var current_mode: Mode = Mode.SELECT_FILE

func _gui_input(event: InputEvent) -> void:
    if Input.is_action_just_pressed_by_event("ui_cancel", event):
        switch_to.emit(MenuScene.MenuPanel.TITLE)

    elif Input.is_action_just_pressed_by_event("ui_down", event):
        selected_panel= (selected_panel+1)%file_panels.size()
    
    elif Input.is_action_just_pressed_by_event("ui_up", event):
        selected_panel= (selected_panel-1)%file_panels.size()
        


func on_show() -> void:
    Overlay.info_text.set_scrolling_text("Load which file?")
    selected_panel = 0
    current_mode = Mode.SELECT_FILE
    file_panels[selected_panel].grab_focus.call_deferred()
    
    


func on_hide() -> void:
    pass
