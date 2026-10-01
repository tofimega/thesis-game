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
@export var powerup_action: PlayerMovementState:
    set(a):
        powerup_action = a
        movement_states[State.POWERUP_ACTION] = a

@onready var animation_handler: AnimationHandler = $AnimationHandler
@onready var damage_taker: DamageTaker = $DamageTaker
@onready var direction: Direction = $Direction
@onready var carry_handler: CarryHandler = $CarryHandler
@onready var pickup_timer: Timer = $PickupTimer
@onready var throw_timer: Timer = $ThrowTimer
@onready var invin_timer: Timer = $InvinTimer
@onready var knockback_timer: Timer = $KnockbackTimer
@onready var health: Health = $Health
@onready var knockback_handler: KnockBackHandler = $KnockBackHandler


func _ready() -> void:
    SceneControl.health_sprite.on = true
    SceneControl.health_sprite.health = health.health
    health.health_changed.connect(SceneControl.health_sprite.set_health)


func _physics_process(_delta: float) -> void:
    var ms: PlayerMovementState = movement_states[_get_movement_state()]
    animation_handler.switch_anim(_get_movement_state())
    ms.process_state(self)


func reset() -> void:
    pickup_timer.stop()
    damage_taker.reset()
    throw_timer.stop()
    knockback_timer.stop()
    invin_timer.stop()
    carry_handler.clear_carry()
    animation_handler.flicker = false
    direction.face_direction = Direction.Dir.UP
    knockback_handler.set_physics_process(false)
    health.health = health.starting_health


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
