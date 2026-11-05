class_name FireAtTargetState
extends EnemyState

signal fired

@export var bullet: PackedScene
@export_node_path("Targeter") var targeter: NodePath

var targeter_node: Targeter


func check_switch(_enemy: Enemy) -> void:
    fired.emit()


func process_enemy(_enemy: Enemy, _delta: float) -> void:
    pass


func enter_state(_enemy: Enemy) -> void:
    var node: Node2D = bullet.instantiate()
    node.top_level = true
    node.rotation = targeter_node.get_direction_to_target().angle()
    node.position = targeter_node.position


func exit_state(_enemy: Enemy) -> void:
    pass


func init_state(enemy: Enemy) -> void:
    targeter_node = enemy.get_node(targeter)
