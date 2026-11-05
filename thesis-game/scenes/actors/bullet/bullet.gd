class_name BulletMovement
extends CharacterBody2D

@export var bullet_collision_scene: PackedScene

func _ready() -> void:
    var node: Area2D = bullet_collision_scene.instantiate()
    add_child.call_deferred(node)
    node.area_entered.connect(_on_hit.unbind(1))
    node.body_entered.connect(_on_hit.unbind(1))

func _physics_process(_delta: float) -> void:
    move_and_slide()

func _on_hit()->void:
    queue_free()
