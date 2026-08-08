@abstract
class_name PlayerMovementState
extends Resource


@abstract func is_valid(player: Player) -> bool


@abstract func process_movement(player: Player) -> void


func process_state(player: Player) -> void:
    process_movement(player)
