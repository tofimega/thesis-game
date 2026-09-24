class_name BlockState
extends EnemyState

@export_node_path("Area2D") var range_detect: NodePath

@export var allow_bodies: bool = true
@export var allow_areas: bool = true

@export var prioritize_layers: PackedByteArray

signal object_entered
signal object_exited
signal new_target
signal aggro_exceeded


var range_shape: Area2D
var priority_lists: Dictionary
var aggro_list: Dictionary[CollisionObject2D, int]

enum TieBReaker{
    LEAST_RECENT,
    MOST_RECENT
}

func check_switch(enemy: Enemy) -> void: pass


func process_enemy(enemy: Enemy, delta: float) -> void: pass


func init_state(enemy: Enemy) -> void:
    range_shape = enemy.get_node(range_detect)
    if allow_bodies:
        range_shape.area_entered.connect(target_in)
        range_shape.area_exited.connect(target_in)
    if allow_areas:
        range_shape.body_entered.connect(target_in)
        range_shape.body_exited.connect(target_in)


func enter_state(enemy: Enemy) -> void: pass


func exit_state(enemy: Enemy) -> void: pass


func target_in(t: CollisionObject2D) -> void:
    pass


func target_out(t: CollisionObject2D) -> void:
    pass
