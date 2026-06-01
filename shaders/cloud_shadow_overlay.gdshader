shader_type canvas_item;

uniform vec4 shadow_color : source_color = vec4(0.16, 0.12, 0.22, 0.22);
uniform vec2 drift = vec2(0.035, 0.018);
uniform float scale = 3.4;
uniform float softness = 0.34;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(
		mix(hash(i + vec2(0.0, 0.0)), hash(i + vec2(1.0, 0.0)), u.x),
		mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x),
		u.y
	);
}

float fbm(vec2 p) {
	float value = 0.0;
	float amplitude = 0.55;
	for (int i = 0; i < 4; i++) {
		value += noise(p) * amplitude;
		p *= 2.05;
		amplitude *= 0.5;
	}
	return value;
}

void fragment() {
	vec2 uv = SCREEN_UV * scale + TIME * drift;
	float cloud = fbm(uv);
	float mask = smoothstep(0.50 - softness, 0.74, cloud);
	COLOR = vec4(shadow_color.rgb, shadow_color.a * mask);
}
