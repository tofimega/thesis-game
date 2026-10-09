class_name LevelEndScreen
extends ColorRect

@onready var level_clear_text: Label = $LevelClearText
@onready var powerup_text: Label = $PowerupText


func reset() -> void:
    level_clear_text.visible_ratio = 0
    powerup_text.visible_ratio = 0
    color.a = 0


func fade(alpha: float, time: float = 1) -> void:
    await create_tween().tween_property(self, "color:a", alpha, time).finished


func display_level_text(level_index: int, time: float = 1) -> void:
    await _display_text(level_clear_text, "Level "+str(level_index)+" clear!", time)


func display_powerup_text(powerup_name: String, time: float = 1) -> void:
    await _display_text(powerup_text, "You got: "+powerup_name, time)
    


func _display_text(label :Label, text: String, time :float = 1)->void:
    label.text=text
    label.visible_ratio = 0
    await create_tween().tween_property(label, "visible_ratio", 1, time).finished
