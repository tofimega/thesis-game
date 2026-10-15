shader_type canvas_item;

instance uniform bool flicker_on = false;

void fragment() {
    if (COLOR.a < .01) discard;
	if (!flicker_on){
        COLOR = texture(TEXTURE, UV);
    }
    else{
        COLOR = vec4(1,1,1,1);
    }
}