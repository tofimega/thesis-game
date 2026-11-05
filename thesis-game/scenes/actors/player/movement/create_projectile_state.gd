class_name CreateProjectileState
extends PlayerMovementState

@export var offset_distance: float = 8
@export var rotate: bool = false
@export var projectile: PackedScene
@export var delay: float = 1


func process_movement(player: Player) -> void:
    if Input.is_action_just_pressed("action_b") and player.general_action_timer.is_stopped():
        var node: Node2D = projectile.instantiate()
        if rotate: node.rotation = player.direction.rotation
        #node.top_level = true
        SceneControl.insert_into_game(node)
        node.global_position = player.center.global_position + (player.direction.get_vector() * offset_distance)
        player.general_action_timer.start(delay)
