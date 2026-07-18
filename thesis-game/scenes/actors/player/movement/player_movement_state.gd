@abstract
class_name PlayerMovementState
extends Resource

@export var animation_name: StringName


@abstract func is_valid() -> bool


@abstract func process_movement(player: Player) -> void
