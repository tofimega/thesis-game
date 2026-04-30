extends Node2D


@export var nodes : Array[Node2D]

@export var camera : Camera2D



func _ready() -> void:
	nodes.reverse()
	camera.global_position = nodes.pop_back().global_position


var a: bool = false
func _process(delta: float) -> void:
	if a: return
	
	if Input.is_action_just_pressed("ui_accept"):
		var t :Tween = create_tween()
		t.tween_property(camera, "global_position", nodes.pop_back().global_position, 3).set_trans(Tween.TRANS_LINEAR)
		t.tween_callback(func (): a = false)
		a=true
