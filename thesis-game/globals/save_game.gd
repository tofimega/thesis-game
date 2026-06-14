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
static var _loaded_at: int = -1
static var _last_saved_playtime: int = -1


static func update_flag(flag: SaveFlag, value: int) -> void:
    assert(_save_index >= 0, "No save file loaded")
    assert(_data.size() == SaveFlag.size(), "Save data is invalid")

    _data[flag] = value
    signals.state_updated.emit(flag, value)


static func save_game() -> bool:
    assert(_save_index >= 0)
    var path: String = SAVE_FOLDER + str(_save_index)

    if !DirAccess.dir_exists_absolute(SAVE_FOLDER):
        DirAccess.make_dir_recursive_absolute(SAVE_FOLDER)

    if FileAccess.file_exists(path):
        var err: Error = DirAccess.copy_absolute(path, path + ".tmp")
        if err != Error.OK:
            push_error("backup could not be created: " + error_string(err))
            return false

    var save_file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
    if save_file == null:
        push_error("Save File exists but could not be opened: " + error_string(FileAccess.get_open_error()))

    if !_write_header(save_file):
        push_error("Save error")
        _restore_backup(_save_index)
        return false

    if !save_file.store_64(_data.size()):
        push_error("Save data could not be created")
        _restore_backup(_save_index)
        return false

    if !save_file.store_buffer(_data):
        push_error("Save data could not be created")
        _restore_backup(_save_index)
        return false

    return true


static func _restore_backup(file: int) -> void:
    var path: String = SAVE_FOLDER + str(file)
    var err: Error = DirAccess.rename_absolute(path + ".tmp", path)
    if err != Error.OK:
        push_error("The backup save could not be restored: " + error_string(err))


static func copy_file(from: int, to: int) -> bool:
    assert(from >= 0)
    assert(to >= 0)
    if from == to: return true
    var from_path: String = SAVE_FOLDER + str(from)
    var to_path: String = SAVE_FOLDER + str(to)
    if !FileAccess.file_exists(SAVE_FOLDER + str(from)): push_error("The file could not be found")
    var err: Error = DirAccess.copy_absolute(from_path, to_path)
    if err != OK:
        push_error("The file could not be copied: " + error_string(err))
        return false
    return true


static func _write_header(save_file: FileAccess) -> bool:
    assert(save_file != null)
    assert(_save_index >= 0)
    assert(_last_saved_playtime >= 0)
    assert(_loaded_at >= 0)
    var header: SaveHeader = SaveHeader.new()
    header.new_game = false
    header.timestamp = Time.get_datetime_dict_from_system()
    header.playtime = _last_saved_playtime + Time.get_ticks_usec() - _loaded_at
    header.completion = _calc_completion()
    return header.store_header(save_file)


static func _calc_completion() -> float:
    # TODO: do this
    return 1


static func delete_file(file: int) -> bool:
    assert(file >= 0)
    var path: String = SAVE_FOLDER + str(file)
    if !FileAccess.file_exists(path): return true
    var err: Error = DirAccess.remove_absolute(path)
    if err != OK:
        push_error("The file could not be deleted: " + error_string(err))
        return false
    return true


static func load_game(file: int) -> SaveHeader:
    assert(file >= 0, "Save file index invalid")
    var path: String = SAVE_FOLDER + str(file)
    _data.clear()
    _save_index = -1
    if !FileAccess.file_exists(path):
        var err: Error = _data.resize(SaveFlag.size()) as Error
        if err != OK:
            push_error("Save file could not be opened: " + error_string(err))
            return null

        _loaded_at = Time.get_ticks_usec()
        return SaveHeader.new()

    var save_file: FileAccess = FileAccess.open(path, FileAccess.READ)

    var rt: SaveHeader = _get_file_header(save_file)

    if rt == null:
        push_error("The file could not be loaded")
        return null

    _last_saved_playtime = rt.playtime

    if save_file.get_64() != SaveFlag.size():
        push_error("Save file is invalid")
        return null

    _data = save_file.get_buffer(SaveFlag.size())
    _save_index = file

    _loaded_at = Time.get_ticks_usec()
    return rt


static func get_file_header(file: int) -> SaveHeader:
    var path: String = SAVE_FOLDER + str(file)
    if !FileAccess.file_exists(path): return SaveHeader.new()
    var save_file: FileAccess = FileAccess.open(path, FileAccess.READ)
    if save_file == null:
        push_error("The file could not be opened: " + error_string(FileAccess.get_open_error()))
        return null
    return _get_file_header(save_file)


static func _get_file_header(file: FileAccess) -> SaveHeader:
    assert(file != null)
    return SaveHeader.from_file(file)


class SaveHeader extends RefCounted:
    var new_game: bool = true
    var timestamp: Dictionary = { "year": 0, "month": 0, "day": 0, "hour": 0, "minute": 0 }
    var completion: float = 0.0
    var playtime: int = 0


    func store_header(save_file: FileAccess) -> bool:
        assert(save_file != null)
        return save_file.store_pascal_string(Time.get_datetime_string_from_datetime_dict(timestamp, false)) && \
        save_file.store_double(completion) && \
        save_file.store_64(playtime)


    static func from_file(save_file: FileAccess) -> SaveHeader:
        assert(save_file != null)
        var rt: SaveHeader = SaveHeader.new()
        rt.new_game = false
        rt.timestamp = Time.get_datetime_dict_from_datetime_string(save_file.get_pascal_string(), false)
        rt.completion = save_file.get_double()
        rt.playtime = save_file.get_64()
        return rt


    func eq(other: SaveHeader) -> bool:
        return new_game == other.new_game && \
        timestamp.keys().all(func(a: Variant) -> bool:
                return other.timestamp.has(a) && other.timestamp[a] == timestamp[a]) && \
        completion == other.completion && \
        playtime == other.playtime


class Signals:
    signal state_updated(flag: SaveFlag, value: int)
