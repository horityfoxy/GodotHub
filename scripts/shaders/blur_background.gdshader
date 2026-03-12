shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float blur_amount : hint_range(0.0, 5.0) = 2.0;

void fragment() {
	vec4 blurred_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur_amount);
	COLOR.rgb = mix(blurred_color.rgb, COLOR.rgb, COLOR.a);
	COLOR.a = 1.0;
}