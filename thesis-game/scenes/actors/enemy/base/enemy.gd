class_name Enemy
extends CharacterBody2D

signal kill_me

@export var states: Array[EnemyState]
@export var counted: bool = false
@export var direction_override: Direction

var switches: Dictionary[StringName, Callable]
var current_state: EnemyState

@onready var health: Health = $Health
@onready var damage_taker: DamageTaker = $DamageTaker
@onready var bomb_damage_taker: DamageTaker = $BombDamageTaker
@onready var direction: Direction = $Direction
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
    if direction_override:
        direction.queue_free()
        direction = direction_override
    for i: int in states.size():
        var s: EnemyState = states[i]
        assert(s != null, "Slot " + str(i) + " has no state")
        s.init_state(self)
        for sw: StringName in s.signal_switches:
            assert(s.has_signal(sw), "State " + str(i) + " has no signal with name " + sw)
    # assert(states.has(s.signal_switches[sw]), "State machine does not have this state registered")
    _switch_state(0)


func _physics_process(delta: float) -> void:
    current_state.check_switch(self)
    current_state.process_enemy(self, delta)


func _switch_state(state: int) -> void:
    if current_state:
        for s: StringName in switches: current_state.disconnect(s, switches[s])
        current_state.exit_state(self)

    switches.clear()
    current_state = states[state]
    for s: StringName in current_state.signal_switches:
        var c: Callable = _switch_state.bind(current_state.signal_switches[s])
        var err: Error = current_state.connect(s, c)
        if err != OK:
            push_error(error_string(err))
        switches[s] = c

    animated_sprite_2d.play(current_state.anim_name)
    current_state.enter_state(self)


func _on_damage_taker_hit(_from: Vector2) -> void:
    if !current_state.can_hurt: return
    health.health -= 1


func _on_bomb_damage_taker_hit(_from: Vector2) -> void:
    if !current_state.can_explode: return
    kill_me.emit()


func _animation_over() -> void:
    if current_state.animation_end_switch >= 0:
        _switch_state(current_state.animation_end_switch)


func _on_health_depleted() -> void:
    kill_me.emit()
