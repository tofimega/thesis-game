class_name Health
extends Node

signal health_depleted

@export var starting_health: int = 3

@onready var health: int = starting_health:
    set(h):
        health = h
        if h <= 0: health_depleted.emit()
