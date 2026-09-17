class_name PlayerWalkState
extends PlayerMovementState

@export var movement_speed: float = 30
@export var carry_movement_speed: float = 15




func process_movement(player: Player) -> void:
    var _input_vec: Vector2 = Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
    player.velocity = _input_vec.normalized() * (movement_speed if player.carry_handler.get_carry_state() == CarryHandler.CarryState.FREE else carry_movement_speed)
    player.direction.set_dir_from_vector(player.velocity)
    player.move_and_slide()
