class_name CarryController
extends Node2D

@onready var player: Player = $Player
@onready var bomb: Bomb = $Bomb
@onready var explosion: Explosion = $Explosion


func try_carry() -> void:
    if bomb.bomb_mode != Bomb.BombMode.INACTIVE: return
    player.do_carry(bomb)
    


func try_throw() -> void:
    if bomb.bomb_mode != Bomb.BombMode.CARRIED: return
    player.do_throw()
    


func on_explosion() -> void:
    player.reset_carry_state()
    explosion.spawn(bomb.global_position)
