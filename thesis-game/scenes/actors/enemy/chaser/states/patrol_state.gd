class_name PatrolState
extends EnemyState

signal wall_hit
signal player_detected

@export var velocity: float
@export var player_detection_range: float = 64

@export_group("Nodes")
@export_node_path("RayCast2D") var raycast: NodePath
@export_flags_2d_physics var ignore_raycast_layers: int

var raycast_node: RayCast2D


func check_switch(enemy: Enemy) -> void:
    if raycast_node:
        raycast_node.target_position = enemy.direction.get_vector() * player_detection_range
        raycast_node.force_raycast_update()
        
        if !raycast_node.is_colliding(): return
        
        var raycast_coll: int = raycast_node.collision_mask
        var coll_layer: int
        var collision: Node2D = raycast_node.get_collider()
        
        if collision is TileMapLayer:
            coll_layer = collision.tile_set.get_physics_layer_collision_layer(0)
        elif collision is CollisionObject2D: coll_layer = collision.collision_layer 
        else: assert(false, "unhandled collision type: "+collision.get_class())
            
        # ignore what we can't collide with
        var ignore: int = ignore_raycast_layers & raycast_coll
        coll_layer &= raycast_coll
        
        # if any set in coll_layer thet isn't set in ignore: emit collision event       
        ignore = ~ignore
        if ignore & coll_layer != 0: player_detected.emit()


func process_enemy(enemy: Enemy, _delta: float) -> void:
    enemy.velocity = enemy.direction.get_vector() * velocity
    if enemy.move_and_slide():
        wall_hit.emit()


func init_state(enemy: Enemy) -> void:
    raycast_node = enemy.get_node_or_null(raycast)


func enter_state(_enemy: Enemy) -> void:
    pass


func exit_state(_enemy: Enemy) -> void:
    pass
