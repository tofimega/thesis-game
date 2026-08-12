class_name Enemy
extends CharacterBody2D

@export var states: Array[EnemyState]

var switches: Dictionary[StringName, Callable]

var current_state: EnemyState

@onready var health: Health = $Health
@onready var damage_taker: DamageTaker = $DamageTaker
@onready var bomb_damage_taker: DamageTaker = $BombDamageTaker
@onready var direction: Direction = $Direction
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
    current_state = states[0]


func _physics_process(delta: float) -> void:
    current_state.check_switch(self)
    current_state.process_enemy(self, delta)


func _switch_state(state: EnemyState) -> void:
    if current_state:
        for s: StringName in switches: current_state.disconnect(s, switches[s])
        current_state.exit_state(self)

    switches.clear()
    current_state = state
    for s: StringName in current_state.signal_switches:
        var c: Callable = _switch_state.bind(current_state.signal_switches[s])
        var err: Error = current_state.connect(s, c)
        if err != OK:
            push_error(error_string(err))
        switches[s] = c

    current_state.enter_state(self)
