class_name KnockBackHandler
extends Node

@export var knockback_body: CharacterBody2D
@export var knockback_speed: float
@export var knockback_timer: Timer

var _damage_source: Vector2


func _ready() -> void:
    set_physics_process(false)
    await get_tree().process_frame
    knockback_timer.timeout.connect(set_physics_process.bind(false))


func _physics_process(_delta: float) -> void:
    knockback_body.velocity = -_damage_source * knockback_speed
    knockback_body.move_and_slide()


func start_knockback(source_pos: Vector2) -> void:
    _damage_source = source_pos
    set_physics_process(true)
    knockback_timer.start()
