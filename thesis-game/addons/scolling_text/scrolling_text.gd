# from: https://forum.godotengine.org/t/how-to-animate-long-text-on-a-label/123802/5
class_name ScrollingLabel
extends RichTextLabel

var final_offset: float
var scroll_offset: float
var return_offset: float
var tween: Tween
var tween_duration: float
var current_text: String


func _ready() -> void:
    scroll_active = false
    autowrap_mode = TextServer.AUTOWRAP_OFF
    check_tween()


func _process(_delta: float) -> void:
    if current_text != text:
        await get_tree().process_frame
        current_text = text
        check_tween()


## Checks if the current text overflows the bounds and needs to be tweened
func check_tween() -> void:
    if tween:
        tween.kill()
        offset_left = 0
    if current_text.length() > 4:
        # Calculate the final offset
        scroll_offset = -(get_content_width() - custom_minimum_size.x)
        return_offset = offset_left
        # we do a little math to make the scroll speed variable based on text length
        tween_duration = absf(scroll_offset) / 100 * 3

        _tween(scroll_offset)


## Creates the text scroll tween
func _tween(offset: float) -> void:
    # Create the tween
    tween = create_tween()
    tween.finished.connect(_repeat_tween)
    final_offset = offset
    # and tween the offset to a neg value so that it moves right
    tween.tween_property(self, "offset_left", final_offset, tween_duration) #.set_delay(1)


## Switches the scroll direction 
func _repeat_tween() -> void:
    # returns to the OG offset (aka moves left)
    if final_offset < 0:
        offset_left = get_content_width()
        _tween(return_offset)
    # scrolls back to the right
    else:
        _tween(scroll_offset)
