class_name WaitForTimeoutState
extends EnemyState

signal wait_over

@export var wait_time: float = 1

var _over: bool = false

var _timer: SceneTreeTimer = null

func init_state(_enemy: Enemy) -> void:
    pass

func check_switch(_enemy: Enemy) -> void:
    if _over:
        wait_over.emit()


func enter_state(enemy: Enemy) -> void:
    _over = false
    _timer = enemy.get_tree().create_timer(wait_time)
    _timer.timeout.connect(_set_over)


func exit_state(_enemy: Enemy) -> void:
    if is_instance_valid(_timer):
        _timer.timeout.disconnect(_set_over)


func process_enemy(_enemy: Enemy, _delta: float) -> void:
    pass


func _set_over() -> void:
    _over = true
