class_name AnimationHandler
extends AnimatedSprite2D

@export var animations: Dictionary[Player.State, StringName]

var flicker: bool:
    set = set_flicker

var _current_state: Player.State = Player.State.SPAWN
var current_animation: StringName = ""
var _carry_state: CarryHandler.CarryState = CarryHandler.CarryState.FREE

@onready var timer: Timer = $Timer
@onready var direction: Direction = $"../Direction"


func set_flicker(on: bool) -> void:
    flicker = on
    if flicker:
        timer.start()
    else:
        timer.stop()
        visible = true


func switch_anim(state: Player.State) -> void:
    _current_state = state
    var anim_name: StringName = _get_anim_name(_current_state)
    current_animation = anim_name
    var dir_anim_name: StringName = anim_name + "_" + direction.Dir.find_key(direction.face_direction).to_lower()

    if sprite_frames.has_animation(dir_anim_name): play(dir_anim_name)
    elif sprite_frames.has_animation(anim_name): play(anim_name)

    if _carry_state == CarryHandler.CarryState.CARRY:
        var carry_anim_name: StringName = anim_name + "_carry"
        var dir_carry_anim_name: StringName = dir_anim_name + "_carry"
        if sprite_frames.has_animation(dir_carry_anim_name): play(dir_carry_anim_name)
        elif sprite_frames.has_animation(carry_anim_name): play(carry_anim_name)


func _get_anim_name(state: Player.State) -> StringName:
    return animations[state]


func _on_carry_state_changed(state: CarryHandler.CarryState) -> void:
    _carry_state = state


func _on_timer_timeout() -> void:
    visible = !visible
