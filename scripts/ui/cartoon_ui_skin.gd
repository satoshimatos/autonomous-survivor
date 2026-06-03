extends RefCounted

const OUTLINE := Color(0.02, 0.025, 0.035, 1.0)
const BUTTON_NORMAL := Color(0.18, 0.32, 0.48, 1.0)
const BUTTON_HOVER := Color(0.28, 0.62, 0.78, 1.0)
const BUTTON_PRESSED := Color(0.95, 0.45, 0.16, 1.0)
const BUTTON_DISABLED := Color(0.16, 0.17, 0.2, 1.0)


static func apply_button(button: Button, accent: Color = BUTTON_NORMAL) -> void:
	button.add_theme_stylebox_override("normal", make_button_style(accent, 4))
	button.add_theme_stylebox_override("hover", make_button_style(BUTTON_HOVER, 5))
	button.add_theme_stylebox_override("pressed", make_button_style(BUTTON_PRESSED, 3))
	button.add_theme_stylebox_override("disabled", make_button_style(BUTTON_DISABLED, 4))
	button.add_theme_color_override("font_color", Color(1.0, 0.96, 0.78, 1.0))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color(0.05, 0.04, 0.03, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.55, 0.57, 0.62, 1.0))
	button.add_theme_color_override("font_outline_color", OUTLINE)
	button.add_theme_constant_override("outline_size", 4)
	attach_button_motion(button)


static func apply_option_button(button: OptionButton) -> void:
	apply_button(button, Color(0.22, 0.42, 0.58, 1.0))


static func make_button_style(fill_color: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_color = OUTLINE
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(10)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.42)
	style.shadow_size = 4
	style.shadow_offset = Vector2(0, 3)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style


static func apply_label_pop(label: Label, color: Color = Color(1.0, 0.93, 0.45, 1.0)) -> void:
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", OUTLINE)
	label.add_theme_constant_override("outline_size", 5)


static func attach_button_motion(button: Button) -> void:
	if button.has_meta("juice_motion_connected"):
		return
	button.set_meta("juice_motion_connected", true)
	button.mouse_entered.connect(func(): animate_button(button, Vector2(1.045, 1.045), -0.012, 0.09))
	button.focus_entered.connect(func(): animate_button(button, Vector2(1.045, 1.045), -0.012, 0.09))
	button.mouse_exited.connect(func(): animate_button(button, Vector2.ONE, 0.0, 0.12))
	button.focus_exited.connect(func(): animate_button(button, Vector2.ONE, 0.0, 0.12))
	button.button_down.connect(func(): animate_button(button, Vector2(0.965, 0.965), 0.018, 0.055))
	button.button_up.connect(func():
		var target_scale := Vector2.ONE
		var target_rotation := 0.0
		if button.has_focus():
			target_scale = Vector2(1.045, 1.045)
			target_rotation = -0.012
		animate_button(button, target_scale, target_rotation, 0.09)
	)


static func animate_button(button: Button, target_scale: Vector2, target_rotation: float, duration: float) -> void:
	if button == null or not is_instance_valid(button):
		return
	button.pivot_offset = button.size * 0.5
	var tween := button.create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", target_scale, duration)
	tween.tween_property(button, "rotation", target_rotation, duration)
