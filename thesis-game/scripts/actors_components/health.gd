class_name Health
extends Node

@export var starting_health: int = 3

@onready var health: int = starting_health:
    set(h):
        health = h
        if h <=0: health_depleted.emit()

signal health_depleted
