extends ColorRect

const FADE_SPEED: float = 3.5
const MAX_ALPHA: float = 0.3

var target_alpha: float = 0.0
var current_alpha: float = 0.0
var pulse_time: float = 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	color = Color.WHITE
	material = create_vignette_material()


func _process(delta: float) -> void:
	pulse_time += delta
	current_alpha = move_toward(current_alpha, target_alpha, FADE_SPEED * delta)
	(material as ShaderMaterial).set_shader_parameter("vignette_alpha", get_pulsed_alpha())


func set_low_health_active(active: bool) -> void:
	target_alpha = MAX_ALPHA if active else 0.0


func get_pulsed_alpha() -> float:
	var pulse: float = 0.85 + sin(pulse_time * TAU * 1.3) * 0.15
	return current_alpha * pulse


func create_vignette_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;

uniform float vignette_alpha = 0.0;
uniform vec4 vignette_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);

void fragment() {
	vec2 centered = UV * 2.0 - 1.0;
	float distance_from_center = length(centered * vec2(0.82, 1.18));
	float mask = smoothstep(0.52, 1.04, distance_from_center);
	COLOR = vec4(vignette_color.rgb, vignette_alpha * mask);
}
"""
	var shader_material := ShaderMaterial.new()
	shader_material.shader = shader
	shader_material.set_shader_parameter("vignette_alpha", 0.0)
	shader_material.set_shader_parameter("vignette_color", Color(1.0, 0.0, 0.0, 1.0))
	return shader_material
