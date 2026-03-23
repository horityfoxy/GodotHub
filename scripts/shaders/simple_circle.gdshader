shader_type canvas_item;

uniform float edge_smoothing : hint_range(0.0, 0.1) = 0.01;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	vec2 center_uv = UV - 0.5;
	float dist = length(center_uv);
	float radius = 0.5;
	float circle_mask = 1.0 - smoothstep(radius - edge_smoothing, radius, dist);
	tex_color.a *= circle_mask;
	COLOR = tex_color;
}