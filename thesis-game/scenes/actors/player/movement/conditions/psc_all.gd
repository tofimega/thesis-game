class_name AllCondition
extends CompoundCondition


func is_valid(player: Player)->bool:
    return subconditions.all(p.bind(player))
