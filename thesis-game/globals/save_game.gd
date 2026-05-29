extends Node

signal state_updated(flag: SaveFlag, value: int)

signal save_begin
signal save_finish(ok: bool)

signal load_begin
signal load_finish(ok: bool)

enum SaveFlag {
	
}

var _data: PackedByteArray = []
var _save_index: int = -1

const SAVE_FOLDER: String = "user://save/"

func update_flag(flag: SaveFlag, value: int) -> void:
	assert(_save_index >= 0, "No save file loaded")
	assert(_data.size() == SaveFlag.size(), "Save data is invalid")
	
	_data[flag] = value
	state_updated.emit(flag, value)


func save_game()->bool:
	assert(_save_index >=0)
	var path: String = SAVE_FOLDER + str(_save_index)
	save_begin.emit()
	
	if !DirAccess.dir_exists_absolute(SAVE_FOLDER): DirAccess.make_dir_recursive_absolute(SAVE_FOLDER)
	
	if FileAccess.file_exists(path):
		var err: Error = DirAccess.copy_absolute(path, path+".tmp")
		if err != Error.OK:
			push_error("backup could not be created: "+error_string(err))
			save_finish.emit(false)
			return false
			
	var save_file: FileAccess = FileAccess.open(SAVE_FOLDER+str(_save_index), FileAccess.WRITE)
	if save_file == null: push_error("Save File exists but could not be opened: " + error_string(FileAccess.get_open_error()))
	
	if !save_file.store_buffer(_data):
		push_error("Save data could not be created")
		var err : Error = DirAccess.rename_absolute(path+".tmp", path)
		if err != Error.OK: push_error("The backup save could not be restored: "+error_string(err))
		save_finish.emit(false)
		return false

	save_finish.emit(true)
	return true

func _do_load(file: int)->bool:
	assert(file >= 0, "Save file index invalid")
	var path: String = SAVE_FOLDER+str(file)
	load_begin.emit()
	_data.clear()
	_save_index = -1
	if !FileAccess.file_exists(path):
		var err: Error = _data.resize(SaveFlag.size()) as Error
		if err != OK:
			push_error("Save file could not be opened: " + error_string(err))
			load_finish.emit(false)
			return false

	var save_file: FileAccess = FileAccess.open(path, FileAccess.READ)
	
	if save_file.get_length() != SaveFlag.size():
		push_error("Save file is invalid")
		load_finish.emit(false)
		return false
	
	_data = save_file.get_buffer(SaveFlag.size())
	_save_index = file
	
	load_finish.emit(true)
	return true
