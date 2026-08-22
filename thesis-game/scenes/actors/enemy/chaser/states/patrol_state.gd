class_name PatrolState
extends EnemyState

signal wall_hit
signal player_detected

@export var velocity: float
@export var player_detection_range: float = 64

@export_group("Nodes")
@export_node_path("RayCast2D") var raycast: NodePath

var raycast_node: RayCast2D


func check_switch(enemy: Enemy) -> void:
    if raycast_node:
        raycast_node.target_position = enemy.direction.get_vector()*player_detection_range
        raycast_node.force_raycast_update()
        if raycast_node.is_colliding(): player_detected.emit()


func process_enemy(enemy: Enemy, _delta: float) -> void:
    enemy.velocity = enemy.direction.get_vector() * velocity
    if enemy.move_and_slide():
        wall_hit.emit()


func init_state(enemy: Enemy) -> void:
    raycast_node = enemy.get_node(raycast)


func enter_state(enemy: Enemy) -> void:
    pass


func exit_state(enemy: Enemy) -> void:
    pass
