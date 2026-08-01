class_name AnimationTimeoutState
extends PlayerMovementState

@export_node_path("Timer") var timer_node: NodePath

func is_valid(player: Player) -> bool:
    return !player.get_node(timer_node).is_stopped()


func process_movement(_player: Player) -> void:
    pass
