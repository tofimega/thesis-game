extends Area2D

@export var lifetime: float = 1

func _ready() -> void:
    get_tree().create_timer(lifetime).timeout.connect(queue_free)
