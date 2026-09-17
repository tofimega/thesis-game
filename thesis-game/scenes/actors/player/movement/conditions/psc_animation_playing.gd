extends PlayerStateCondition

@export var animation_name: StringName

func is_valid(player: Player)->bool:
    return player.animation_handler._current_animation == animation_name
