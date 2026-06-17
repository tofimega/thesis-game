class_name SaveGame
extends Object

enum SaveFlag {
    a,
    c,
    vb,
    g,
}

enum ErrorCode {
    OK,
    SAVE_CANT_OPEN,
    SAVE_HEADER_WRITE_FAILED,
    SAVE_DATA_WRITE_FAILED,
    SAVE_BACKUP_FAILED,
    SAVE_RESTORE_BACKUP_FAILED,
    LOAD_FLAG_INIT_ERROR,
    LOAD_CANT_OPEN,
    LOAD_BAD_BUFFER_SIZE,
}

const SAVE_FOLDER: String = "user://save/"

static var signals: Signals = Signals.new():
    set(s):
        pass

static var _data: PackedByteArray = []
static var _save_index: int = -1
static var _loaded_at: int = -1
static var _last_saved_playtime: int = -1


static func _report_error(error: ErrorCode, info: String = "", push_to: Array[ErrorCode] = []) -> ErrorCode:
    push_to.push_back(error)

    if error == ErrorCode.OK: return error

    var error_name: StringName = ErrorCode.find_key(error)
    if error_name.begins_with("LOAD"):
        _error_load(error, info)

    elif error_name.begins_with("SAVE"):
        var backup_status: Error = _error_save(error, info)
        if backup_status != OK:
            return ErrorCode.SAVE_RESTORE_BACKUP_FAILED

    else: assert(false, "error name not recognized")

    return error


static func _error_load(error: ErrorCode, info: String = "") -> void:
    var err_string: String = "LOAD FAILED: "
    match error:
        ErrorCode.LOAD_FLAG_INIT_ERROR: err_string += "save flags could not be initialized while attempting to start new game"
        ErrorCode.LOAD_CANT_OPEN: err_string += "save file exists but could not be opened"
        ErrorCode.LOAD_BAD_BUFFER_SIZE: err_string += "incompatible file format: number of flags in file is not " + str(SaveFlag.size())
        _: assert(false, "wrong error")

    if info != "": err_string += " (" + info + ")"
    push_error(err_string)
    signals.load_finish.emit(error)
    _save_index = -1


static func _error_save(error: ErrorCode, info: String = "") -> Error:
    var err_string: String = "SAVE FAILED: "
    match error:
        ErrorCode.SAVE_CANT_OPEN: err_string += "the file exists but could not be opened"
        ErrorCode.SAVE_HEADER_WRITE_FAILED: err_string += "the header could not be written"
        ErrorCode.SAVE_DATA_WRITE_FAILED: err_string += "the save data could not be written"
        ErrorCode.SAVE_BACKUP_FAILED: err_string += "backup file could not be created"
        ErrorCode.SAVE_RESTORE_BACKUP_FAILED: assert(false, "this is special")
        _: assert(false, "wrong error")

    if info != "": err_string += " (" + info + ")"

    push_error(err_string)
    signals.save_finish.emit(error)
    return _restore_backup(_save_index)


static func update_flag(flag: SaveFlag, value: int) -> void:
    assert(_save_index >= 0, "No save file loaded")
    assert(_data.size() == SaveFlag.size(), "Save data is invalid")

    _data[flag] = value
    signals.state_updated.emit(flag, value)


static func save_game() -> ErrorCode:
    assert(_save_index >= 0, "No save file loaded")
    signals.save_begin.emit()
    var path: String = SAVE_FOLDER + str(_save_index)

    if !DirAccess.dir_exists_absolute(SAVE_FOLDER):
        DirAccess.make_dir_recursive_absolute(SAVE_FOLDER)

    if FileAccess.file_exists(path):
        var err: Error = DirAccess.copy_absolute(path, path + ".tmp")
        if err != Error.OK:
            return _report_error(ErrorCode.SAVE_BACKUP_FAILED, error_string(err))

    var save_file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
    if save_file == null:
        return _report_error(ErrorCode.SAVE_CANT_OPEN, error_string(FileAccess.get_open_error()))

    if !_write_header(save_file):
        return _report_error(ErrorCode.SAVE_HEADER_WRITE_FAILED)

    if !save_file.store_64(_data.size()):
        return _report_error(ErrorCode.SAVE_DATA_WRITE_FAILED, "Data buffer size could not be written")

    if !save_file.store_buffer(_data):
        return _report_error(ErrorCode.SAVE_DATA_WRITE_FAILED, "Save flags could not be written")

    signals.save_finish.emit(ErrorCode.OK)
    return ErrorCode.OK


static func _restore_backup(file: int) -> Error:
    var path: String = SAVE_FOLDER + str(file)
    var err: Error = DirAccess.rename_absolute(path + ".tmp", path)
    if err != Error.OK:
        push_error("The backup save could not be restored: " + error_string(err))
        return err
    return OK


static func copy_file(from: int, to: int) -> Error:
    assert(from >= 0, "Invalid file index")
    assert(to >= 0, "Invalid file index")
    if from == to: return OK
    var from_path: String = SAVE_FOLDER + str(from)
    var to_path: String = SAVE_FOLDER + str(to)
    if !FileAccess.file_exists(SAVE_FOLDER + str(from)): push_error("The file could not be found")
    var err: Error = DirAccess.copy_absolute(from_path, to_path)
    if err != OK:
        push_error("The file could not be copied: " + error_string(err))
        return err
    return OK


static func _write_header(save_file: FileAccess) -> bool:
    assert(save_file != null, "No file provided")
    assert(_save_index >= 0, "No save file loaded")
    assert(_last_saved_playtime >= 0, "Save file invalid")
    assert(_loaded_at >= 0, "Save file invalid")
    var header: SaveHeader = SaveHeader.new()
    header.new_game = false
    header.timestamp = Time.get_datetime_dict_from_system()
    header.playtime = _last_saved_playtime + Time.get_ticks_usec() - _loaded_at
    header.completion = _calc_completion()
    return header.store_header(save_file)


static func _calc_completion() -> float:
    # TODO: do this
    return 1


static func delete_file(file: int) -> Error:
    assert(file >= 0, "Invalid file")
    var path: String = SAVE_FOLDER + str(file)
    if !FileAccess.file_exists(path): return ERR_FILE_NOT_FOUND
    var err: Error = DirAccess.remove_absolute(path)
    if err != OK:
        push_error("The file could not be deleted: " + error_string(err))
        return err
    return OK


static func load_game(file: int, error: Array[ErrorCode]) -> SaveHeader:
    assert(file >= 0, "Save file index invalid")
    signals.load_begin.emit(file)
    var path: String = SAVE_FOLDER + str(file)
    _data.clear()
    _save_index = -1
    if !FileAccess.file_exists(path):
        var err: Error = _data.resize(SaveFlag.size()) as Error
        if err != OK:
            _report_error(ErrorCode.LOAD_FLAG_INIT_ERROR, error_string(err), error)
            return null

        _loaded_at = Time.get_ticks_usec()
        _save_index = file
        _last_saved_playtime = 0
        signals.load_finish.emit(ErrorCode.OK)
        return SaveHeader.new()

    var save_file: FileAccess = FileAccess.open(path, FileAccess.READ)

    if save_file == null:
        _report_error(ErrorCode.LOAD_CANT_OPEN, "", error)
        return null

    var rt: SaveHeader = _get_file_header(save_file)

    _last_saved_playtime = rt.playtime

    var flags: int = save_file.get_64()
    if flags != SaveFlag.size():
        _report_error(ErrorCode.LOAD_BAD_BUFFER_SIZE, str(flags), error)
        return null

    _data = save_file.get_buffer(SaveFlag.size())
    _save_index = file

    _loaded_at = Time.get_ticks_usec()
    signals.load_finish.emit(ErrorCode.OK)
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
    assert(file != null, "No file provided")
    return SaveHeader.from_file(file)


class SaveHeader extends RefCounted:
    var new_game: bool = true
    var timestamp: Dictionary = { "year": 0, "month": 0, "day": 0, "hour": 0, "minute": 0 }
    var completion: float = 0.0
    var playtime: int = 0


    func store_header(save_file: FileAccess) -> bool:
        assert(save_file != null, "No file provided")
        return save_file.store_pascal_string(Time.get_datetime_string_from_datetime_dict(timestamp, false)) && \
        save_file.store_double(completion) && \
        save_file.store_64(playtime)


    static func from_file(save_file: FileAccess) -> SaveHeader:
        assert(save_file != null, "No file provided")
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
    signal save_begin
    signal save_finish(error: ErrorCode)
    signal load_begin(file: int)
    signal load_finish(error: ErrorCode)
