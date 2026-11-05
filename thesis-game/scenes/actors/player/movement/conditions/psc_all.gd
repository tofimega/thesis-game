class_name AllCondition
extends CompoundCondition


func is_valid(player: Player)->bool:
    return subconditions.all(func (c: PlayerStateCondition)->bool: return c.is_valid(player))
