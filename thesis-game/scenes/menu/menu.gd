class_name MenuScene
extends Control

enum MenuPanel {
    TITLE,
    FILE_SELECT,
    LEVEL_SCELECT,
}

var current_panel: Submenu = null

@onready var title_screen: Submenu = $ReferenceRect/TitleScreen
@onready var file_select: Submenu = $ReferenceRect/FileSelect
@onready var level_select: Submenu = $ReferenceRect/LevelSelect
@onready var panels: Dictionary[MenuPanel, Submenu] = {
    MenuPanel.TITLE: title_screen,
    MenuPanel.FILE_SELECT: file_select,
    MenuPanel.LEVEL_SCELECT: level_select,
}


func _ready() -> void:
    panels.make_read_only()
    SceneControl.health_sprite.on = false
    for p: Submenu in panels.values():
        p.visible = false
        p.set_process_input(false)
    


func switch_panel(panel: MenuPanel) -> void:
    assert(panels.has(panel), "incorrect mode")
    var fade: bool = current_panel==level_select or panel == MenuPanel.LEVEL_SCELECT
    if current_panel:
        if fade:
            var f: Control = get_viewport().gui_get_focus_owner()
            if f: f.release_focus()
            await SceneControl.fade_loading(1, .3)
        current_panel.release_focus()
        current_panel.visible = false
        current_panel.set_process_input(false)
        current_panel.on_hide()

    current_panel = panels[panel]
    current_panel.visible = true
    current_panel.grab_focus.call_deferred()
    current_panel.set_process_input(true)
    current_panel.switch_to.connect(switch_panel, CONNECT_ONE_SHOT)
    current_panel.on_show()
    if fade: await SceneControl.fade_loading(0, .3)
    
