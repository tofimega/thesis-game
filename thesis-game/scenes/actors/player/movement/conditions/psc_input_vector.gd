class_name InputVectorCondition
extends PlayerStateCondition

@export var up: StringName
@export var down: StringName
@export var left: StringName
@export var right: StringName

@export var deadzone: float = 0

func is_valid(_player: Player)->bool:
    return Input.get_vector(left, right, up, down).length() > deadzone
