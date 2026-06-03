# from: https://forum.godotengine.org/t/how-to-animate-long-text-on-a-label/123802/5
class_name ScrollingLabel
extends RichTextLabel

@export_range(1, 50, 1, "or_greater") var scroll_speed: float = 50
@export_range(0, 10, .5, "or_greater") var repeat_delay: float = 0

var tween: Tween


func _ready() -> void:
    scroll_active = false
    autowrap_mode = TextServer.AUTOWRAP_OFF
    position.x = custom_minimum_size.x
    set_scrolling_text(text)


func set_scrolling_text(text: String) -> void:
    self.text = text
    await get_tree().process_frame
    check_tween()


## Checks if the current text overflows the bounds and needs to be tweened
func check_tween() -> void:
    if tween:
        tween.kill()

    if get_content_width() > custom_minimum_size.x:
        _tween()
    else:
        position.x = 0


## Creates the text scroll tween
func _tween() -> void:
    # Create the tween
    tween = create_tween()
    tween.finished.connect(_repeat_tween)
    position.x = custom_minimum_size.x
    # Calculate the final offset
    var scroll_offset: float = -get_content_width()
    var distance: float = absf(position.x - scroll_offset)
    var tween_duration: float = distance / scroll_speed
    # and tween the offset to a neg value so that it moves right
    tween.tween_property(self, "position:x", scroll_offset, tween_duration).set_delay(repeat_delay)


## Switches the scroll direction 
func _repeat_tween() -> void:
    check_tween()
