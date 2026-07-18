class_name AnimationHandler
extends AnimatedSprite2D

enum AnimationState {
    IDLE,
    WALK,
    HURT,
    SPAWN,
    DESPAWN,
    THROW,
    LIFT,
}

@export var animations: Dictionary[AnimationState, StringName]

var _current_state: AnimationState = AnimationState.SPAWN


func switch_anim(state: AnimationState) -> void:
    _current_state = state
    var anim_name: StringName = _get_anim_name(_current_state)
    play(anim_name)


func _get_anim_name(state: AnimationState) -> StringName:
    return animations[state]
