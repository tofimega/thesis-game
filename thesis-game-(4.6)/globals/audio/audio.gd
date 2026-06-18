extends Node

var _available_players: Array[AudioStreamPlayer]
var _fade_tween: Tween

@onready var _music: AudioStreamPlayer = $Music
@onready var _one_shot: Node = $OneShot


func play_one_shot(sound: AudioStream) -> void:
    var a: AudioStreamPlayer

    if _available_players.is_empty():
        a = AudioStreamPlayer.new()
        a.autoplay = true
        a.stream = sound
        a.bus = &"Sounds"

    else:
        a = _available_players.pop_back()
        a.stream = sound

    a.finished.connect(_free_player.bind(a), CONNECT_ONE_SHOT)
    _one_shot.add_child(a)


func play_music(sound: AudioStream, fade_out: float = .3, fade_in: float = 0) -> void:
    if _fade_tween:
        _fade_tween.kill()
    var bus_index: int = AudioServer.get_bus_index(&"Music")
    if _music.playing:
        stop_music(fade_out)
    else:
        _fade_tween = create_tween()
    _fade_tween.tween_property(_music, "stream", sound, 0)
    _fade_tween.tween_property(_music, "playing", true, 0)
    _fade_tween.tween_method(AudioServer.set_bus_volume_linear.bind(bus_index), 0, 1, fade_in)


func stop_music(fade_time: float = .3) -> void:
    if _fade_tween:
        _fade_tween.kill()
    var bus_index: int = AudioServer.get_bus_index(&"Music")
    _fade_tween = create_tween()
    _fade_tween.tween_method(AudioServer.set_bus_volume_linear.bind(bus_index), AudioServer.get_bus_volume_linear(bus_index), 0, fade_time)
    _fade_tween.tween_property(_music, "playing", false, 0)


func _free_player(a: AudioStreamPlayer) -> void:
    a.get_parent().remove_child(a)
    _available_players.push_back(a)
