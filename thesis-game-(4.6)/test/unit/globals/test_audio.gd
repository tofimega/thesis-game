extends GutTest

const TEST_TONE: AudioStream = preload("uid://bfpmb2qi0uxu6")


func test_music_bus() -> void:
    assert_eq(Audio._music.bus, &"Music")


func test_play_music() -> void:
    Audio.play_music(TEST_TONE, 0, 0)
    await wait_process_frames(1)
    assert_eq(Audio._music.stream, TEST_TONE)
    assert_true(Audio._music.playing)


func test_stop_music() -> void:
    Audio.stop_music(0)
    await wait_process_frames(1)
    assert_false(Audio._music.playing)


func test_play_one_shot() -> void:
    Audio.play_one_shot(TEST_TONE)
    assert_true(Audio._one_shot.get_child_count() > 0)
    var stream_players: Array[Node] = Audio._one_shot.get_children().filter(func(a: AudioStreamPlayer) -> bool: return a.stream == TEST_TONE)

    assert_false(stream_players.is_empty())
    var player: AudioStreamPlayer = stream_players[0]
    var finished: bool = await wait_for_signal(player.finished, TEST_TONE.get_length() + 1)

    if !finished:
        return

    await wait_process_frames(1)

    assert_null(player.get_parent())
    assert_true(Audio._available_players.has(player))
