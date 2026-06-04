class_name FilePanel
extends Button

enum Mode {
    SHOW_INFO,
    FILE_OPTIONS,
    COPY_CHOICER,
    DELETE_CHOICER,
}

@onready var select: Button = $HBoxContainer/Info/Options/Options/HBoxContainer/Select
@onready var copy: Button = $HBoxContainer/Info/Options/Options/HBoxContainer/Copy
@onready var delete: Button = $HBoxContainer/Info/Options/Options/HBoxContainer/Delete

@onready var yes: Button = $HBoxContainer/Info/Choicer/Display/VBoxContainer/HBoxContainer2/Yes
@onready var no: Button = $HBoxContainer/Info/Choicer/Display/VBoxContainer/HBoxContainer2/No
@onready var choicer_label: Label = $HBoxContainer/Info/Choicer/Display/VBoxContainer/ChoicerLabel

@export var file_num: int = -1

signal load_file(file: int)
signal copy_begin(file: int)
signal delete_file(file: int)
signal copy_confirm(file: int)
signal choicer_canceled(file: int)


@onready var panels: Dictionary[Mode, Control] = {
    Mode.SHOW_INFO: $HBoxContainer/Info/InfoPanel,
    Mode.FILE_OPTIONS: $HBoxContainer/Info/Options,
    Mode.COPY_CHOICER: $HBoxContainer/Info/Choicer,
    Mode.DELETE_CHOICER: $HBoxContainer/Info/Choicer
}

var choicer_text: Dictionary[Mode, String] = {
    Mode.COPY_CHOICER: "Copy here?",
    Mode.DELETE_CHOICER: "Delete file?"
}

var current_mode: Mode = Mode.SHOW_INFO:
    set = set_mode

func _ready() -> void:
    for c: Control in panels.values():
        c.visible = false
        
    current_mode = Mode.SHOW_INFO
    
    pressed.connect(set_mode.bind(Mode.FILE_OPTIONS))
    select.pressed.connect(load_file.emit.bind(file_num))
    copy.pressed.connect(copy_begin.emit.bind(file_num))
    delete.pressed.connect(set_mode.bind(Mode.DELETE_CHOICER))
    yes.pressed.connect(evaluate_choicer)
    no.pressed.connect(cancel_choicer)
    
func cancel_choicer()->void:
    choicer_canceled.emit(file_num)
    current_mode = Mode.FILE_OPTIONS

func evaluate_choicer()->void:
    match current_mode:
        Mode.COPY_CHOICER: copy_confirm.emit(file_num)
        Mode.DELETE_CHOICER: delete_file.emit(file_num)
        _: assert(false, "Incorrect choicer mode")
        
    current_mode = Mode.SHOW_INFO

func set_mode(mode: Mode)->void:
    assert(panels.has(mode))
    
    if panels.has(current_mode):
        panels[current_mode].visible = false
    
    current_mode = mode
    
    panels[current_mode].visible = true
    
    match current_mode:
        Mode.SHOW_INFO:
            grab_focus.call_deferred()
        Mode.FILE_OPTIONS:
            select.grab_focus.call_deferred()
        Mode.COPY_CHOICER, Mode.DELETE_CHOICER:
            assert(choicer_text.has(current_mode))
            choicer_label.text = choicer_text[current_mode]
            no.grab_focus()
        _: assert(false, "No action given")
