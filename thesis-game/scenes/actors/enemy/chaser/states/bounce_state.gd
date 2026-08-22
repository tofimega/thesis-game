class_name BounceState
extends HopState

@export var distance: float = 16


func enter_state(_enemy: Enemy) -> void:
    super(_enemy)
    _enemy.direction.set_dir_from_vector(-_enemy.direction.get_vector())


func process_enemy(_enemy: Enemy, _delta: float) -> void:
    super(_enemy, _delta)
    if !timer_node: return
    _enemy.velocity = _enemy.direction.get_vector() * (distance / timer_node.wait_time)
    _enemy.move_and_slide()
