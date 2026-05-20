shader_type canvas_item;

uniform float max_alpha = 0.34;
uniform float gray_saturation_threshold = 0.24;
uniform float gray_brightness_floor = 0.24;
uniform float edge_softness = 0.12;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	float max_channel = max(color.r, max(color.g, color.b));
	float min_channel = min(color.r, min(color.g, color.b));
	float saturation = max_channel <= 0.001 ? 0.0 : (max_channel - min_channel) / max_channel;
	float low_saturation = 1.0 - smoothstep(gray_saturation_threshold, gray_saturation_threshold + edge_softness, saturation);
	float bright_enough = smoothstep(gray_brightness_floor, gray_brightness_floor + edge_softness, max_channel);
	float background_amount = low_saturation * bright_enough;
	float alpha = color.a * max_alpha * (1.0 - background_amount);
	COLOR = vec4(color.rgb, alpha);
}
