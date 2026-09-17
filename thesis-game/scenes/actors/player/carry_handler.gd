class_name CarryHandler
extends RemoteTransform2D

signal try_carry
signal try_throw
signal carry_set(state: CarryState)

enum CarryState {
    CARRY,
    FREE,
}

var _carry_state: CarryState = CarryState.FREE:
    set(s): 
        _carry_state = s
        carry_set.emit(s)




func _input(_event: InputEvent) -> void:
    if Input.is_action_just_pressed("action_a"):
        match _carry_state:
            CarryState.FREE: try_carry.emit()
            CarryState.CARRY: try_throw.emit()


func get_carry_state() -> CarryState:
    return _carry_state


func set_carry(bomb: Bomb) -> void:
    _carry_state = CarryState.CARRY
    bomb.bomb_mode = Bomb.BombMode.CARRIED
    remote_path = bomb.get_path()
    
func clear_carry()->void:
    _carry_state = CarryState.FREE
    remote_path = ^""
