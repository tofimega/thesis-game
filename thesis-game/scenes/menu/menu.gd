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
    for p: Submenu in panels.values():
        p.visible = false
        p.set_process_input(false)
    switch_panel(MenuPanel.TITLE)


func switch_panel(panel: MenuPanel) -> void:
    assert(panels.has(panel))

    if current_panel:
        current_panel.visible = false
        current_panel.set_process_input(false)

    current_panel = panels[panel]

    current_panel.visible = true
    current_panel.set_process_input(true)
    current_panel.switch_to.connect(switch_panel, CONNECT_ONE_SHOT)
