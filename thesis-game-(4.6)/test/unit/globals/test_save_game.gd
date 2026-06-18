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
        assert_false(result.new_game)
        assert_eq(result.completion, SaveGame._calc_completion())
        assert_eq(result.playtime, SaveGame._last_saved_playtime)


    func test_load_new_game() -> void:
        if FileAccess.file_exists(FPATH):
            DirAccess.remove_absolute(FPATH)

        var err: Array[SaveGame.ErrorCode]
        var header: SaveGame.SaveHeader = SaveGame.load_game(RESERVED_SAVE_INDEX, err)
        if err.is_empty():
            assert_eq(SaveGame._calc_completion(), 0.0)
            assert_eq(SaveGame._last_saved_playtime, 0)
            assert_eq(SaveGame._save_index, RESERVED_SAVE_INDEX)
            assert_not_null(header)
            assert_true(header.new_game)
            assert_eq(header.completion, SaveGame._calc_completion())
            assert_eq(header.playtime, SaveGame._last_saved_playtime)
            var _test_data: PackedByteArray
            _test_data.resize(SaveGame.SaveFlag.size())
            assert_eq(SaveGame._data, _test_data)
        else:
            assert_null(header)
            assert_eq(SaveGame._save_index, -1)


class TestSave extends GutTest:
    var FPATH: String = SaveGame.SAVE_FOLDER + str(RESERVED_SAVE_INDEX):
        set(a):
            pass


    func before_each() -> void:
        SaveGame.load_game(RESERVED_SAVE_INDEX, [])


    func test_save_signals() -> void:
        watch_signals(SaveGame.signals)
        SaveGame.save_game()
        assert_signal_emit_count(SaveGame.signals.save_begin, 1)

        assert_signal_emit_count(SaveGame.signals.save_finish, 1)
        if get_errors().is_empty():
            assert_signal_emitted_with_parameters(SaveGame.signals.save_finish, [SaveGame.ErrorCode.OK])
            return


    func test_backup_deleted_on_success() -> void:
        var file_data: FileAccess = FileAccess.open(FPATH, FileAccess.READ)
        var file_bytes: PackedByteArray = file_data.get_buffer(file_data.get_length())
        file_data.close()
        var err: SaveGame.ErrorCode = SaveGame.save_game()

        match err:
            SaveGame.ErrorCode.SAVE_RESTORE_BACKUP_FAILED:
                assert_true(FileAccess.file_exists(FPATH + ".tmp"))
            SaveGame.ErrorCode.OK:
                assert_false(FileAccess.file_exists(FPATH + ".tmp"))
            _:
                assert_false(FileAccess.file_exists(FPATH + ".tmp"))
                file_data = FileAccess.open(FPATH, FileAccess.READ)
                assert_eq(file_data.get_buffer(file_data.get_length()), file_bytes)


    func test_error_if_no_file() -> void:
        SaveGame._save_index = -1
        SaveGame.save_game()
        assert_engine_error_count(1)


    func test_save_correct_flags() -> void:
        for i: int in SaveGame.SaveFlag.size():
            SaveGame.update_flag(i, randi_range(0, 255))
        SaveGame.save_game()

        var file: FileAccess = FileAccess.open(FPATH, FileAccess.READ)
        SaveGame.SaveHeader.from_file(file)
        assert_eq(file.get_64(), SaveGame.SaveFlag.size())
        var buffer: PackedByteArray = file.get_buffer(SaveGame.SaveFlag.size())
        assert_eq(SaveGame._data, buffer)


class TestParse extends GutTest:

    var FPATH: String = SaveGame.SAVE_FOLDER + str(RESERVED_SAVE_INDEX):
        set(a):
            pass


    func before_all() -> void:
        SaveGame.load_game(RESERVED_SAVE_INDEX, [])
        SaveGame.save_game()


    func test_parse_existing_file() -> void:
        var header: SaveGame.SaveHeader = SaveGame.get_file_header(RESERVED_SAVE_INDEX)

        if header == null:
            assert_push_error_count(1)
            return
        assert_false(header.new_game)
        var file_data: FileAccess = FileAccess.open(FPATH, FileAccess.READ)
        assert_true(header.eq(SaveGame.SaveHeader.from_file(file_data)))


    func test_parse_no_file() -> void:
        var header: SaveGame.SaveHeader = SaveGame.get_file_header(RESERVED_SAVE_INDEX + 1)
        assert_true(header.eq(SaveGame.SaveHeader.new()))


class TestFlag extends GutTest:


    func before_each() -> void:
        SaveGame.load_game(RESERVED_SAVE_INDEX, [])


    func test_set_flag() -> void:
        var value: int = randi_range(0, 255)
        var flag: SaveGame.SaveFlag = randi_range(0, SaveGame.SaveFlag.size()-1) as SaveGame.SaveFlag
        watch_signals(SaveGame.signals)
        SaveGame.update_flag(flag, value)
        assert_signal_emit_count(SaveGame.signals.state_updated, 1)
        assert_signal_emitted_with_parameters(SaveGame.signals.state_updated, [flag, value])

        assert_eq(SaveGame._data[flag], value)


    func test_no_file() -> void:
        SaveGame._save_index = -1
        SaveGame.update_flag(0 as SaveGame.SaveFlag, 0)
        assert_engine_error_count(1)
