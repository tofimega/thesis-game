class_name FilePanel
extends Button

signal load_file(file: int)
signal copy_begin(file: int)
signal delete_file(file: int)
signal copy_confirm(file: int)
signal choicer_canceled(file: int)

enum Mode {
    SHOW_INFO,
    FILE_OPTIONS,
    COPY_CHOICER,
    DELETE_CHOICER,
}

static var _copy_mode: bool = false

@export var file_num: int = -1:
    set(v):
        file_num = v
        if !is_node_ready(): await ready
        _index_label.text = str(v + 1)
        _file_info = SaveGame.get_file_header(file_num)

var _file_info: SaveGame.SaveHeader:
    set = _update_file_info

var _choicer_text: Dictionary[Mode, String] = {
    Mode.COPY_CHOICER: "Copy here?",
    Mode.DELETE_CHOICER: "Delete file?"
}

var _current_mode: Mode = Mode.SHOW_INFO:
    set = _set_mode

@onready var date: Label = $HBoxContainer/Info/InfoPanel/Display/VBoxContainer/HBoxContainer/Date
@onready var time: Label = $HBoxContainer/Info/InfoPanel/Display/VBoxContainer/HBoxContainer/Time
@onready var playtime: Label = $HBoxContainer/Info/InfoPanel/Display/VBoxContainer/HBoxContainer2/Playtime
@onready var completion: Label = $HBoxContainer/Info/InfoPanel/Display/VBoxContainer/HBoxContainer2/Completion

@onready var _select: Button = $HBoxContainer/Info/Options/Options/HBoxContainer/Select
@onready var _copy: Button = $HBoxContainer/Info/Options/Options/HBoxContainer/Copy
@onready var _delete: Button = $HBoxContainer/Info/Options/Options/HBoxContainer/Delete

@onready var _yes: Button = $HBoxContainer/Info/Choicer/Display/VBoxContainer/HBoxContainer2/Yes
@onready var _no: Button = $HBoxContainer/Info/Choicer/Display/VBoxContainer/HBoxContainer2/No
@onready var _choicer_label: Label = $HBoxContainer/Info/Choicer/Display/VBoxContainer/ChoicerLabel
@onready var _index_label: Label = $HBoxContainer/FileIndex/Panel/Label

@onready var _panels: Dictionary[Mode, Control] = {
    Mode.SHOW_INFO: $HBoxContainer/Info/InfoPanel,
    Mode.FILE_OPTIONS: $HBoxContainer/Info/Options,
    Mode.COPY_CHOICER: $HBoxContainer/Info/Choicer,
    Mode.DELETE_CHOICER: $HBoxContainer/Info/Choicer
}
@onready var _info_new: Control = $HBoxContainer/Info/InfoNew


func _ready() -> void:
    _copy_mode = false
    file_num = file_num
    for c: Control in _panels.values():
        c.visible = false

    _current_mode = Mode.SHOW_INFO

    pressed.connect(_handle_press)
    _select.pressed.connect(load_file.emit.bind(file_num))
    _copy.pressed.connect(_begin_copy)
    _delete.pressed.connect(_set_mode.bind(Mode.DELETE_CHOICER))
    _yes.pressed.connect(_evaluate_choicer)
    _no.pressed.connect(_cancel_choicer)


func _unhandled_input(event: InputEvent) -> void:
    if _current_mode == Mode.SHOW_INFO: return
    if Input.is_action_just_pressed_by_event("ui_cancel", event):
        match _current_mode:
            Mode.COPY_CHOICER, Mode.DELETE_CHOICER:
                _cancel_choicer()
            _: _current_mode = Mode.SHOW_INFO

        get_viewport().set_input_as_handled()


func _handle_press() -> void:
    if _copy_mode: _current_mode = Mode.COPY_CHOICER
    else: _current_mode = Mode.FILE_OPTIONS


func _update_file_info(file_header: SaveGame.SaveHeader) -> void:
    _file_info = file_header
    _copy.disabled = _file_info.new_game
    _delete.disabled = _file_info.new_game

    date.text = "{day}/{month}/{year}".format(
        {"day": str(_file_info.timestamp.get("day")).pad_zeros(2),
        "month": str(_file_info.timestamp.get("month")).pad_zeros(2),
        "year": str(_file_info.timestamp.get("year")).pad_zeros(4)})

    time.text = "{hour}:{minute}".format({
        "hour": str(_file_info.timestamp.get("hour")).pad_zeros(2),
        "minute": str(_file_info.timestamp.get("minute")).pad_zeros(2)
        })

    @warning_ignore_start("integer_division")
    var playt_sec: int = _file_info.playtime / 1_000_000
    var playt_min: int = playt_sec / 60
    @warning_ignore_restore("integer_division")

    playt_sec -= playt_min * 60

    playtime.text = "{minute}:{second}".format({
        "minute": str(playt_min).pad_zeros(3),
        "second": str(playt_sec).pad_zeros(2)
        })
    
    completion.text = "{comp_perc}%".format({
        "comp_perc": str(int(_file_info.completion*100)).pad_zeros(3)
        })

    _current_mode = Mode.SHOW_INFO


func _begin_copy() -> void:
    _copy_mode = true
    _current_mode = Mode.SHOW_INFO
    copy_begin.emit(file_num)


func _cancel_choicer() -> void:
    choicer_canceled.emit(file_num)
    _current_mode = Mode.FILE_OPTIONS


func _evaluate_choicer() -> void:
    match _current_mode:
        Mode.COPY_CHOICER: 
            copy_confirm.emit(file_num)
            _copy_mode = false
        Mode.DELETE_CHOICER: delete_file.emit(file_num)
        _: assert(false, "Incorrect choicer mode")

    file_num = file_num
    _current_mode = Mode.SHOW_INFO


func _set_mode(mode: Mode) -> void:
    assert(_panels.has(mode), "Incorrect mode")

    if _panels.has(_current_mode):
        _panels[_current_mode].visible = false
    _info_new.visible = false

    _current_mode = mode

    if mode == Mode.SHOW_INFO and (!_file_info or _file_info.new_game):
        _info_new.visible = true
    else: _panels[_current_mode].visible = true

    match _current_mode:
        Mode.SHOW_INFO:
            grab_focus.call_deferred()
        Mode.FILE_OPTIONS:
            _select.grab_focus.call_deferred()
        Mode.COPY_CHOICER, Mode.DELETE_CHOICER:
            assert(_choicer_text.has(_current_mode), "No choicer text provided for this mode")
            _choicer_label.text = _choicer_text[_current_mode]
            _no.grab_focus.call_deferred()
        _: assert(false, "No action given")
