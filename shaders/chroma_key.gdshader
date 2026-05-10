shader_type canvas_item;

uniform vec4 key_color : source_color = vec4(0.0, 1.0, 0.0, 1.0);
uniform float tolerance = 0.34;
uniform float softness = 0.12;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	float distance_to_key = distance(color.rgb, key_color.rgb);
	float alpha = smoothstep(tolerance, tolerance + softness, distance_to_key);
	COLOR = vec4(color.rgb, color.a * alpha);
}
