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

@export var animations: Dictionary[Player.State, StringName]
@onready var direction: Direction = $"../Direction"

var _current_state: Player.State = Player.State.SPAWN


func switch_anim(state: Player.State) -> void:
    _current_state = state
    var anim_name: StringName = _get_anim_name(_current_state)
    play(anim_name +"_"+direction.Dir.find_key(direction.face_direction).to_lower())


func _get_anim_name(state: Player.State) -> StringName:
    return animations[state]
