class_name LevelMap
extends Resource

@export_file("*.tscn") var map: Array [String]
@export var clear_flags: Dictionary[int, SaveGame.SaveFlag]
@export var unlock_power_on_clear: Dictionary[int, PlayerMovementState]
