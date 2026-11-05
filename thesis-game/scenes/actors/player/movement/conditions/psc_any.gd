class_name AnyCondition
extends CompoundCondition


func is_valid(player: Player)->bool:
    return subconditions.any(func (c: PlayerStateCondition)->bool: return c.is_valid(player))
