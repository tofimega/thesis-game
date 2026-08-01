class_name PlayerWalkState
extends PlayerMovementState

@export var input_deadzone: float = .2
@export var movement_speed: float = 30
@export var carry_movement_speed: float = 15

var _input_vec: Vector2


func is_valid(_player: Player) -> bool:
    _input_vec = Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
    return _input_vec.length() > input_deadzone


func process_movement(player: Player) -> void:
    player.velocity = _input_vec.normalized() * movement_speed # TODO: carry handler
    player.direction.set_dir_from_vector(player.velocity)
    player.move_and_slide()
    
