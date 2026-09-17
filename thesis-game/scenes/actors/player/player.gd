class_name Player
extends CharacterBody2D

signal want_throw
signal want_carry

enum State {
    SPAWN,
    DESPAWN,
    DEAD,
    HURT,
    POWERUP_ACTION,
    THROW,
    PICKUP,
    WALK,
    IDLE,
}

@export var movement_states: Dictionary[State, PlayerMovementState] = {}

@onready var animation_handler: AnimationHandler = $AnimationHandler
@onready var damage_taker: Area2D = $DamageTaker
@onready var direction: Direction = $Direction
@onready var carry_handler: CarryHandler = $CarryHandler
@onready var pickup_timer: Timer = $PickupTimer
@onready var throw_timer: Timer = $ThrowTimer
@onready var invin_timer: Timer = $InvinTimer
@onready var knockback_timer: Timer = $KnockbackTimer


func _physics_process(_delta: float) -> void:
    var ms: PlayerMovementState = movement_states[_get_movement_state()]
    ms.process_state(self)
    animation_handler.switch_anim(_get_movement_state())


func do_carry(bomb: Bomb) -> void:
    bomb.bomb_mode = Bomb.BombMode.CARRIED
    carry_handler.set_carry(bomb)
    pickup_timer.start()


func do_throw() -> void:
    var bomb: Bomb = get_node(carry_handler.remote_path)
    carry_handler.clear_carry()
    bomb.global_position = global_position
    bomb.setup_throw(direction.get_vector())
    throw_timer.start()


func try_throw() -> void:
    match _get_movement_state():
        State.WALK, State.IDLE: want_throw.emit()


func reset_carry_state() -> void:
    carry_handler.clear_carry()


func try_carry() -> void:
    match _get_movement_state():
        State.WALK, State.IDLE: want_carry.emit()
        _: return


func _get_movement_state() -> State:

    for m: String in State:
        var s: State = State.get(m)
        assert(movement_states.has(s))
        if movement_states[s].state_condition && movement_states[s].state_condition.is_valid(self): return s

    return State.IDLE
