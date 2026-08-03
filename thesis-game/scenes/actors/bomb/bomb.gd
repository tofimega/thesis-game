class_name Bomb
extends CharacterBody2D

signal exploded

signal _bomb_hit_ground

enum BombMode {
    INACTIVE,
    CARRIED,
    AIRBORNE,
    GROUNDED,
}

@export var throw_speed: float = 10
@export var max_throw_distance: float = 3 * 16
@export var drop_speed: float = 3
@export var max_drop_distance: float = 1 * 16
@export var visual_offset_mult: float = 3
var bomb_mode: BombMode = BombMode.INACTIVE:
    set = set_bomb_mode

var _chosen_dir: Vector2
var _chosen_speed: float
var _chosen_distance: float
var _traveled: float = 0

@onready var fuse_1: Timer = $Fuse1
@onready var short_fuse: Timer = $ShortFuse
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
    if bomb_mode != BombMode.AIRBORNE: return
    velocity = _chosen_dir * _chosen_speed
    
    if _traveled >= _chosen_distance or move_and_slide():
        bomb_mode = BombMode.GROUNDED
        animated_sprite_2d.offset.y = 0
        _bomb_hit_ground.emit()
        return
    _traveled += _chosen_speed * delta
    animated_sprite_2d.offset.y = -sin(remap(_traveled, 0, _chosen_distance, 0, PI)) * visual_offset_mult

func _ready() -> void:
    bomb_mode = BombMode.INACTIVE

func set_bomb_mode(b: BombMode) -> void:
    bomb_mode = b
    match bomb_mode:
        BombMode.INACTIVE:
            z_index = 0
            fuse_1.stop()
            short_fuse.stop()
            set_collision_layer_value(3, false)
            set_collision_mask_value(1, false)
            set_physics_process(false)
            visible = false
        BombMode.CARRIED:
            z_index = 1
            fuse_1.start()
            visible = true
            animated_sprite_2d.play("default")
            set_physics_process(false)
            set_collision_layer_value(3, false)
            set_collision_mask_value(1, false)
        BombMode.AIRBORNE:
            z_index = 1
            visible = true
            set_collision_layer_value(3, false)
            set_physics_process(true)
            set_collision_mask_value(1, true)
        BombMode.GROUNDED:
            z_index = 0
            visible = true
            set_physics_process(false)
            set_collision_layer_value(3, true)
            set_collision_mask_value(1, true)


func setup_throw(direction: Vector2, drop: bool = false) -> void:
    _chosen_dir = direction
    _chosen_speed = drop_speed if drop else throw_speed
    _chosen_distance = max_drop_distance if drop else max_throw_distance
    _traveled = 0
    bomb_mode = BombMode.AIRBORNE


func begin_short_fuse() -> void:
    animated_sprite_2d.play("flash")
    short_fuse.start()


func explode() -> void:
    if bomb_mode == BombMode.AIRBORNE: await _bomb_hit_ground
    exploded.emit()
    bomb_mode = BombMode.INACTIVE
