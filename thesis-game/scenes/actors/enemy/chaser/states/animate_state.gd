class_name AnimateState
extends EnemyState

signal time_over

@export_node_path("Timer") var timer: NodePath

var timer_node: Timer


func init_state(enemy: Enemy) -> void:

    timer_node = enemy.get_node_or_null(timer)
    if timer_node:
        timer_node.timeout.connect(time_over.emit)


func enter_state(_enemy: Enemy) -> void:
    if timer_node:
        timer_node.start()


func exit_state(_enemy: Enemy) -> void:
    if timer_node:
        timer_node.stop()


func check_switch(_enemy: Enemy) -> void: pass


func process_enemy(_enemy: Enemy, _delta: float) -> void: pass
