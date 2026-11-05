class_name BulletMovement
extends CharacterBody2D

@export var bullet_collision_scene: PackedScene

func _ready() -> void:
    add_child.call_deferred(bullet_collision_scene.instantiate())

func _physics_process(_delta: float) -> void:
    move_and_slide()
