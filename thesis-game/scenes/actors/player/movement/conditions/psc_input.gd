class_name InputCondition
extends PlayerStateCondition

enum InputState {
    JUST_PRESSED,
    PRESSED,
    JUST_RELEASED,
    RELEASED,
}

@export var input_action: StringName
@export var input_state: InputState


func is_valid(_player: Player) -> bool:
    match input_state:
        InputState.JUST_PRESSED: return Input.is_action_just_pressed(input_action)
        InputState.PRESSED: return Input.is_action_pressed(input_action)
        InputState.JUST_RELEASED: return Input.is_action_just_released(input_action)
        InputState.RELEASED: return !Input.is_action_pressed(input_action)
        _: return false
