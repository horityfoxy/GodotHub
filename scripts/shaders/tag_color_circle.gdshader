shader_type canvas_item;

void fragment() {
	float d = distance(UV, vec2(0.5));
	float unit = fwidth(d);
	float circle_mask = smoothstep(0.5, 0.5 - unit, d);
	float border_mask = smoothstep(0.43, 0.43 - unit, d);
	vec3 border_color = COLOR.rgb * vec3(1.3);
	COLOR.rgb = mix(border_color, COLOR.rgb, border_mask);
	COLOR.a *= circle_mask;
}