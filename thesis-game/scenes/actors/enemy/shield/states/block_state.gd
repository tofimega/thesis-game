class_name BlockState
extends EnemyState

signal object_entered
signal object_exited
signal new_target
signal aggro_exceeded

enum TieBreaker {
    LEAST_RECENT,
    MOST_RECENT,
}

@export_node_path("Area2D") var range_detect: NodePath
@export var allow_bodies: bool = true
@export var aggro_threshold: float = 3
@export var allow_areas: bool = true
@export var prioritize_layers: PackedByteArray
@export var tiebreaker: TieBreaker

var range_shape: Area2D
var priority_lists: Dictionary[int, Array]
var aggro_list: Dictionary[CollisionObject2D, float]
var in_range: Dictionary[CollisionObject2D, bool]
var last_target: CollisionObject2D = null


func check_switch(_enemy: Enemy) -> void: pass


func process_enemy(enemy: Enemy, delta: float) -> void:
    var target: CollisionObject2D = update_aggro(delta)
    if target == null: return
    if target != last_target: new_target.emit()
    if aggro_list.get_or_add(target, 0) >= aggro_threshold:
        aggro_list[target] = 0
        aggro_exceeded.emit()
        
    enemy.direction.set_dir_from_vector(enemy.global_position.direction_to(target.global_position))


func update_aggro(delta: float) -> CollisionObject2D:
    var selected_list: Array = priority_lists[-1]

    for c: CollisionObject2D in aggro_list.keys():
        if !is_instance_valid(c):
            aggro_list.erase(c)
            continue
        aggro_list[c] = aggro_list[c] + (delta if in_range.get_or_add(c, false) else (-delta))
        print(c.name, ": ", aggro_list[c])
        if aggro_list[c] <= 0: aggro_list.erase(c)
        elif aggro_list[c] > aggro_threshold: aggro_list[c] = aggro_threshold

    for i: int in prioritize_layers:
        if priority_lists[i].is_empty(): continue
        selected_list = priority_lists[i]
        break

    if selected_list.is_empty(): return null
    var index: int = 0
    match tiebreaker:
        TieBreaker.LEAST_RECENT: index = 0
        TieBreaker.MOST_RECENT: index = -1

    var rt: CollisionObject2D = selected_list[index]
    return rt


func init_state(enemy: Enemy) -> void:
    for i: int in prioritize_layers:
        priority_lists[i] = []
    priority_lists[-1] = []

    range_shape = enemy.get_node(range_detect)
    if allow_bodies:
        range_shape.area_entered.connect(target_in)
        range_shape.area_exited.connect(target_out)
    if allow_areas:
        range_shape.body_entered.connect(target_in)
        range_shape.body_exited.connect(target_out)


func enter_state(_enemy: Enemy) -> void:
    aggro_list.clear()


func exit_state(_enemy: Enemy) -> void: pass


func target_in(t: CollisionObject2D) -> void:
    in_range[t] = true
    for i: int in prioritize_layers:
        if t.get_collision_layer_value(i):
            priority_lists[i].append(t)
            aggro_list.get_or_add(t, 0)
            return
        priority_lists[-1].append(t)
        aggro_list.get_or_add(t, 0)
    object_entered.emit()


func target_out(t: CollisionObject2D) -> void:
    in_range.erase(t)
    for l: Array in priority_lists.values():
        var d: Array[CollisionObject2D]
        for c: CollisionObject2D in l:
            if c == t: d.append(c)
        for c: CollisionObject2D in d: l.erase(c)
    object_exited.emit()
