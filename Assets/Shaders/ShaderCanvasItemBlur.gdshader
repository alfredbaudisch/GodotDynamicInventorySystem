shader_type canvas_item;

uniform float blur_amount: hint_range(0.0, 5.0);
uniform sampler2D screen_texture : hint_screen_texture, repeat_enable, filter_linear_mipmap;

void fragment() {
	COLOR.rgb = textureLod(screen_texture, SCREEN_UV, blur_amount).rgb;
}