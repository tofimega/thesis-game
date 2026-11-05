class_name FireAtTargetState
extends EnemyState

signal fired

@export var bullet_movement: PackedScene
@export var bullet_collision: PackedScene
@export var bullet_speed: float = 40
@export_node_path("Targeter") var targeter: NodePath

var targeter_node: Targeter


func check_switch(_enemy: Enemy) -> void:
    fired.emit()


func process_enemy(_enemy: Enemy, _delta: float) -> void:
    pass


func enter_state(_enemy: Enemy) -> void:
    var node: BulletMovement = bullet_movement.instantiate()
    node.bullet_collision_scene = bullet_collision
    SceneControl.insert_into_game(node)
    node.global_position = targeter_node.global_position
    node.velocity = targeter_node.get_direction_to_target() * bullet_speed
    

func exit_state(_enemy: Enemy) -> void:
    pass


func init_state(enemy: Enemy) -> void:
    targeter_node = enemy.get_node(targeter)
