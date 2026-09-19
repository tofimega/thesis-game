class_name NotCondition
extends PlayerStateCondition

@export var subcondition: PlayerStateCondition

func is_valid(player: Player)->bool:
    return !subcondition.is_valid(player)
