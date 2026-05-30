class_name SaveGame
extends Object

enum SaveFlag {
    a,
    c,
    vb,
    g,
}

const SAVE_FOLDER: String = "user://save/"

static var signals: Signals = Signals.new():
    set(s):
        pass
static var _data: PackedByteArray = []
static var _save_index: int = -1


static func update_flag(flag: SaveFlag, value: int) -> void:
    assert(_save_index >= 0, "No save file loaded")
    assert(_data.size() == SaveFlag.size(), "Save data is invalid")

    _data[flag] = value
    signals.state_updated.emit(flag, value)


static func save_game() -> bool:
    assert(_save_index >= 0)
    var path: String = SAVE_FOLDER + str(_save_index)
    signals.save_begin.emit()

    if !DirAccess.dir_exists_absolute(SAVE_FOLDER):
        DirAccess.make_dir_recursive_absolute(SAVE_FOLDER)

    if FileAccess.file_exists(path):
        var err: Error = DirAccess.copy_absolute(path, path + ".tmp")
        if err != Error.OK:
            push_error("backup could not be created: " + error_string(err))
            signals.save_finish.emit(false)
            return false

    var save_file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
    if save_file == null:
        push_error("Save File exists but could not be opened: " + error_string(FileAccess.get_open_error()))

    if !save_file.store_buffer(_data):
        push_error("Save data could not be created")
        var err: Error = DirAccess.rename_absolute(path + ".tmp", path)
        if err != Error.OK:
            push_error("The backup save could not be restored: " + error_string(err))
        signals.save_finish.emit(false)
        return false

    signals.save_finish.emit(true)
    return true


static func load_game(file: int) -> bool:
    assert(file >= 0, "Save file index invalid")
    var path: String = SAVE_FOLDER + str(file)
    signals.load_begin.emit()
    _data.clear()
    _save_index = -1
    if !FileAccess.file_exists(path):
        var err: Error = _data.resize(SaveFlag.size()) as Error
        if err != OK:
            push_error("Save file could not be opened: " + error_string(err))
            signals.load_finish.emit(false)
            return false
        return true

    var save_file: FileAccess = FileAccess.open(path, FileAccess.READ)

    if save_file.get_length() != SaveFlag.size():
        push_error("Save file is invalid")
        signals.load_finish.emit(false)
        return false

    _data = save_file.get_buffer(SaveFlag.size())
    _save_index = file

    signals.load_finish.emit(true)
    return true


class Signals:
    signal state_updated(flag: SaveFlag, value: int)

    signal save_begin
    signal save_finish(ok: bool)

    signal load_begin
    signal load_finish(ok: bool)
