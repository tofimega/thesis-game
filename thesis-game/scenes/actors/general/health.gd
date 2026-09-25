class_name Health
extends Node

signal health_depleted

@export var starting_health: int = 3

@onready var health: int = starting_health:
    set = set_health


func set_health(h: int) -> void:
    health = h
    print(health)
    if h <= 0: health_depleted.emit()


func dec_health(count: int = 1) -> void:
    health -= count


func inc_health(count: int = 1) -> void:
    health += count
