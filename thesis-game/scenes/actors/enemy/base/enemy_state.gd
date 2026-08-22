@abstract
class_name EnemyState
extends Resource

@export var signal_switches: Dictionary[StringName, int]
@export var anim_name: StringName = "default"
@export var can_explode: bool = false
@export var can_hurt: bool = true
@export var animation_end_switch: int = -1

@abstract func check_switch(enemy: Enemy) -> void


@abstract func process_enemy(enemy: Enemy, delta: float) -> void


@abstract func init_state(enemy: Enemy) -> void


@abstract func enter_state(enemy: Enemy) -> void


@abstract func exit_state(enemy: Enemy) -> void
