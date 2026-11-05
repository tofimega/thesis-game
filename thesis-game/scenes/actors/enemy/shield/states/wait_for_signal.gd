class_name WaitForSignal
extends EnemyState

signal signal_received

@export_node_path("Node") var source: NodePath
@export var signal_name: StringName
@export var unbinds: int = 0

var source_node: Node

var _done: bool = false


func check_switch(_enemy: Enemy) -> void:
    if _done: signal_received.emit()


func process_enemy(_enemy: Enemy, _delta: float) -> void:
    pass


func init_state(enemy: Enemy) -> void:
    source_node = enemy.get_node(source)
    source_node.connect(signal_name, _set_signal.unbind(unbinds))


func exit_state(_enemy: Enemy) -> void:
    pass


func enter_state(_enemy: Enemy) -> void:
    _done = false


func _set_signal() -> void:
    _done = true
