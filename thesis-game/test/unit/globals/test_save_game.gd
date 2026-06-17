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


    func test_load_signals_correct_param_load_process_finishes_and_errors_are_reported() -> void:
        watch_signals(SaveGame.signals)
        var load_error: Array[SaveGame.ErrorCode]
        var header: SaveGame.SaveHeader = SaveGame.load_game(RESERVED_SAVE_INDEX, load_error)

        assert_signal_emit_count(SaveGame.signals.load_begin, 1)
        assert_signal_emitted_with_parameters(SaveGame.signals.load_begin, [RESERVED_SAVE_INDEX])

        assert_signal_emit_count(SaveGame.signals.load_finish, 1)

        var errs: Array = get_errors()
        if errs.is_empty():
            assert_true(load_error.is_empty())
            assert_eq(SaveGame._save_index, RESERVED_SAVE_INDEX)
            assert_not_null(header)
            assert_signal_emitted_with_parameters(SaveGame.signals.load_finish, [OK])
        else:
            assert_false(load_error.is_empty())
            assert_push_error_count(load_error.size())
            assert_ne(load_error[0], SaveGame.ErrorCode.OK)
            assert_eq(SaveGame._save_index, -1)
            assert_null(header)


    func test_load_signals_incorrect_param_causes_assertion_failure() -> void:
        SaveGame.load_game(-1, [])
        assert_engine_error_count(1)


    func test_load_correct_flag_count() -> void:
        var load_error: Array[SaveGame.ErrorCode]
        var result: SaveGame.SaveHeader = SaveGame.load_game(RESERVED_SAVE_INDEX, load_error)
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

        var result: SaveGame.SaveHeader = SaveGame.load_game(RESERVED_SAVE_INDEX, [])

        var result_header: SaveGame.SaveHeader = SaveGame.SaveHeader.from_file(save_file)
        assert_true(result_header.eq(result))
        assert_true(result.eq(test_header))
        save_file.get_64()

        var buffer: PackedByteArray = save_file.get_buffer(SaveGame.SaveFlag.size())
        if !result:
            assert_push_error_count(1)
            return
        assert_eq(SaveGame._data, buffer)

# TODO: more thorough tests
class TestSave extends GutTest:
    var FPATH: String = SaveGame.SAVE_FOLDER + str(RESERVED_SAVE_INDEX):
        set(a):
            pass


    func before_each() -> void:
        SaveGame.load_game(RESERVED_SAVE_INDEX, [])


    func test_save_correct_flags() -> void:
        for i: int in SaveGame.SaveFlag.size():
            SaveGame.update_flag(i, randi_range(0, 255))
        SaveGame.save_game()

        var file: FileAccess = FileAccess.open(FPATH, FileAccess.READ)
        SaveGame.SaveHeader.from_file(file)
        assert_eq(file.get_64(), SaveGame.SaveFlag.size())
        var buffer: PackedByteArray = file.get_buffer(SaveGame.SaveFlag.size())
        assert_eq(SaveGame._data, buffer)
