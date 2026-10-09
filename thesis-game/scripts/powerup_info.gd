class_name PowerupInfo
extends Resource

@export_file("*.png") var icon: String
@export var powerup: PlayerMovementState
@export var powerup_name: StringName

func get_texture()->Texture:
    assert(ResourceLoader.exists(icon, "Texture"))
    return load(icon)
