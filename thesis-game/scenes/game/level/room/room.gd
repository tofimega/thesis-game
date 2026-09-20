class_name Room
extends Node2D

signal room_cleared

var enemy_count: int = 0

@onready var dynamic: Node2D = $Offset/Dynamic
@onready var player_spawn: Marker2D = $Offset/PlayerSpawn


func spawn_actors() -> void:
    for p: Node in dynamic.get_children():
        var n: Node
        if p is InstancePlaceholder: n = p.create_instance(true)
        else: n = p
        if n is Enemy: register_enemy(n)


func clear_room() -> void:
    for n: Node in dynamic.get_children():
        n.queue_free()
    enemy_count = 0


func register_enemy(e: Enemy) -> void:
    if e.counted:
        enemy_count += 1
        e.kill_me.connect(remove_enemy.bind(e), CONNECT_ONE_SHOT)


func remove_enemy(e: Enemy) -> void:
    e.queue_free()
    enemy_count -= 1
    if enemy_count <= 0: room_cleared.emit()
