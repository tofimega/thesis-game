extends Control

@onready var loading: TextureRect = $Loading
@onready var main_screen: ColorRect = $MainCRT/ColorRect
@onready var info_text: ScrollingLabel = $InfoTextBase/ColorRect/Label


func _input(event: InputEvent) -> void:
    if !event.is_action_type():
        return
    SceneControl.push_input(event)


func set_viewport(texture: Texture) -> void:
    var mat: ShaderMaterial = main_screen.material
    mat.set_shader_parameter("tex", texture)
