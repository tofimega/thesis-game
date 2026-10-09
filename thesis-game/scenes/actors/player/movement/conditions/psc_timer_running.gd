class_name TimerRunningCondition
extends PlayerStateCondition

@export_node_path("Timer") var timer: NodePath

@export var allow_pause: bool = false

func is_valid(player: Player)->bool:
    var t: Timer = player.get_node(timer) as Timer
    return t and !t.is_stopped() and (allow_pause or !t.paused)
