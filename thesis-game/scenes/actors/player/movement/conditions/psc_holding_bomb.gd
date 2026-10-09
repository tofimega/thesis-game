class_name HoldingBombCondition
extends PlayerStateCondition

func is_valid(player: Player)->bool:
    return player.carry_handler.get_carry_state() == CarryHandler.CarryState.CARRY
