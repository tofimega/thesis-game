extends GutTest

const RESERVED_SAVE_INDEX: int = 9999999

var FPATH: String = SaveGame.SAVE_FOLDER + str(RESERVED_SAVE_INDEX):
    set(a):
        pass


func before_all() -> void:
    DirAccess.make_dir_recursive_absolute(SaveGame.SAVE_FOLDER)
    if FileAccess.file_exists(SaveGame.SAVE_FOLDER + str(RESERVED_SAVE_INDEX)):
        DirAccess.remove_absolute(SaveGame.SAVE_FOLDER + str(RESERVED_SAVE_INDEX))


class TestLoad extends GutTest:
    var FPATH: String = SaveGame.SAVE_FOLDER + str(RESERVED_SAVE_INDEX):
        set(a):
            pass


    func test_load_correct_flag_count() -> void:
        var result: SaveGame.SaveHeader = SaveGame.load_game(RESERVED_SAVE_INDEX)
        if !result:
            assert_push_error_count(1)
            return

        assert_eq(SaveGame._data.size(), SaveGame.SaveFlag.size())


    func test_load_correct_data() -> void:
        var save_file: FileAccess = FileAccess.open(FPATH, FileAccess.WRITE)
        if save_file == null:
            fail_test(error_string(FileAccess.get_open_error()))
            return
        var test_header: SaveGame.SaveHeader = SaveGame.SaveHeader.new()
        test_header.timestamp = Time.get_datetime_dict_from_system()
        test_header.new_game = false
        test_header.store_header(save_file)
        save_file.store_64(SaveGame.SaveFlag.size())
        for i: int in SaveGame.SaveFlag.size():
            save_file.store_8(randi_range(0, 255))

        save_file = FileAccess.open(FPATH, FileAccess.READ)

        var result: SaveGame.SaveHeader = SaveGame.load_game(RESERVED_SAVE_INDEX)

        var result_header: SaveGame.SaveHeader = SaveGame.SaveHeader.from_file(save_file)
        assert_true(result_header.eq(result))
        assert_true(result.eq(test_header))
        save_file.get_64()

        var buffer: PackedByteArray = save_file.get_buffer(SaveGame.SaveFlag.size())
        if !result:
            assert_push_error_count(1)
            return
        assert_eq(SaveGame._data, buffer)


class TestSave extends GutTest:
    var FPATH: String = SaveGame.SAVE_FOLDER + str(RESERVED_SAVE_INDEX):
        set(a):
            pass


    func before_each() -> void:
        SaveGame.load_game(RESERVED_SAVE_INDEX)


    func test_save_correct_flags() -> void:
        for i: int in SaveGame.SaveFlag.size():
            SaveGame.update_flag(i, randi_range(0, 255))
        SaveGame.save_game()

        var file: FileAccess = FileAccess.open(FPATH, FileAccess.READ)
        SaveGame.SaveHeader.from_file(file)
        assert_eq(file.get_64(), SaveGame.SaveFlag.size())
        var buffer: PackedByteArray = file.get_buffer(SaveGame.SaveFlag.size())
        assert_eq(SaveGame._data, buffer)
