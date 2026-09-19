class_name InputVectorCondition
extends PlayerStateCondition

@export var up: StringName
@export var down: StringName
@export var left: StringName
@export var right: StringName

@export var deadzone: float = 0

var last_input: Vector2

func is_valid(_player: Player)->bool:
    last_input = Input.get_vector(left, right, up, down)
    return last_input.length() > deadzone
