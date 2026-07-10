class_name Room
extends Node2D

@onready var dynamic: Node2D = $Offset/Dynamic
@onready var player_spawn: Marker2D = $Offset/PlayerSpawn


func spawn_actors() -> void:
    for p: InstancePlaceholder in dynamic.get_children():
        p.create_instance(true)


func remove_actors() -> void:
    for n: Node in dynamic.get_children():
        n.queue_free()
