@abstract
class_name CompoundCondition
extends PlayerStateCondition

@export var subconditions: Array[PlayerStateCondition]

var p: Callable = func (player: Player, c: PlayerStateCondition)->bool: return c.is_valid(player)




    
