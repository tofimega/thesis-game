class_name Player
extends CharacterBody2D

@export var movement_states: Array[PlayerMovementState] = []

@onready var animation_handler: AnimationHandler = $AnimationHandler
@onready var damage_taker: Area2D = $DamageTaker


func _physics_process(_delta: float) -> void:
    _get_movement_state().process_movement(self)


func _get_movement_state() -> PlayerMovementState:
    for m: PlayerMovementState in movement_states:
        if m.is_valid(): return m

    return movement_states[-1]
