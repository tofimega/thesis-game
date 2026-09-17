@abstract
class_name PlayerMovementState
extends Resource

@export var state_condition: PlayerStateCondition


@abstract func process_movement(player: Player) -> void


func process_state(player: Player) -> void:
    process_movement(player)
