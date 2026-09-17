class_name AnyCondition
extends CompoundCondition


func is_valid(player: Player)->bool:
    return subconditions.any(p.bind(player))
