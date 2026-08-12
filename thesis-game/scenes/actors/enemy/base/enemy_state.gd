@abstract
class_name EnemyState
extends Resource

@export var signal_switches: Dictionary[StringName, EnemyState]


@abstract func check_switch(enemy: Enemy) -> void


@abstract func process_enemy(enemy: Enemy, delta: float) -> void


@abstract func init_state(enemy: Enemy) -> void


@abstract func enter_state(enemy: Enemy) -> void


@abstract func exit_state(enemy: Enemy) -> void


@abstract func can_explode() -> bool


@abstract func can_hurt() -> bool
