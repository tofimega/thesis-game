extends Submenu # file select

enum Mode {
    SELECT_FILE,
    COPY_FILE,
}

@export var file_panels: Array[FilePanel]

var selected_panel: int = 0
var current_mode: Mode = Mode.SELECT_FILE:
    set = _set_mode

var _file_to_copy: int = -1


func _ready() -> void:
    for p: FilePanel in file_panels:
        p.load_file.connect(_load_file)
        p.copy_begin.connect(_copy_begin)
        p.copy_confirm.connect(_copy_file)
        p.delete_file.connect(_delete_file)


func _unhandled_input(event: InputEvent) -> void:
    if Input.is_action_just_pressed_by_event("ui_cancel", event):
        switch_to.emit(MenuScene.MenuPanel.TITLE)


func on_show() -> void:
    current_mode = Mode.SELECT_FILE
    file_panels[0].grab_focus.call_deferred()


func on_hide() -> void:
    pass


func _set_mode(m: Mode) -> void:
    current_mode = m

    match current_mode:
        Mode.SELECT_FILE: Overlay.info_text.set_scrolling_text("Load which file?")
        Mode.COPY_FILE: Overlay.info_text.set_scrolling_text("Copy where?")


func _delete_file(file: int) -> void:
    SaveGame.delete_file(file)


func _copy_file(file: int) -> void:
    assert(_file_to_copy >= 0, "Invalid file")
    SaveGame.copy_file(_file_to_copy, file)
    _file_to_copy = -1
    current_mode = Mode.SELECT_FILE


func _load_file(file: int) -> void:
    var load_error: Array[SaveGame.ErrorCode] = []
    var header: SaveGame.SaveHeader = SaveGame.load_game(file, load_error)

    if !load_error.is_empty(): return # show popup or smth

    if header.new_game: SceneControl.begin_game(0) # jump into game immediately
    else: switch_to.emit(MenuScene.MenuPanel.LEVEL_SCELECT) # open level select


func _copy_begin(file: int) -> void:
    _file_to_copy = file
    current_mode = Mode.COPY_FILE


func _gui_input(event: InputEvent) -> void:
    _unhandled_input(event)
