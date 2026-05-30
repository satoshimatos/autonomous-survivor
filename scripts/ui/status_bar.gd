extends Control

@export var fill_empty_color: Color = Color(0.0, 0.0, 0.0, 1.0)
@export var fill_full_color: Color = Color(1.0, 0.85, 0.0, 1.0)
@export var metallic_dark: Color = Color(0.18, 0.18, 0.18, 1.0)
@export var metallic_mid: Color = Color(0.62, 0.62, 0.58, 1.0)
@export var metallic_light: Color = Color(0.95, 0.92, 0.82, 1.0)
@export var background_color: Color = Color(0.04, 0.04, 0.04, 0.92)
@export var corner_radius: int = 8

var progress: float = 0.0

@onready var label_node: Label = $Label


func set_progress(value: float) -> void:
	progress = clamp(value, 0.0, 1.0)
	queue_redraw()


func set_label_text(value: String) -> void:
	label_node.text = value


func get_fill_end_global_position() -> Vector2:
	var inner_rect := Rect2(Vector2(5.0, 5.0), size - Vector2(10.0, 10.0))
	var fill_x := inner_rect.position.x + inner_rect.size.x * progress
	return global_position + Vector2(fill_x, size.y / 2.0)


func _draw() -> void:
	var outer_rect := Rect2(Vector2.ZERO, size)
	var mid_rect := Rect2(Vector2(2.0, 2.0), size - Vector2(4.0, 4.0))
	var inner_rect := Rect2(Vector2(5.0, 5.0), size - Vector2(10.0, 10.0))
	
	draw_style_box(create_box(metallic_dark, corner_radius), outer_rect)
	draw_style_box(create_box(metallic_mid, max(corner_radius - 2, 1)), mid_rect)
	draw_rect(Rect2(Vector2(4.0, 3.0), Vector2(max(size.x - 8.0, 0.0), 3.0)), metallic_light)
	draw_style_box(create_box(background_color, max(corner_radius - 4, 1)), inner_rect)
	
	var fill_width := inner_rect.size.x * progress
	if fill_width <= 0.0:
		return
	
	var fill_rect := Rect2(inner_rect.position, Vector2(fill_width, inner_rect.size.y))
	var fill_color := fill_empty_color.lerp(fill_full_color, progress)
	draw_style_box(create_box(fill_color, max(corner_radius - 4, 1)), fill_rect)
	
	var highlight_height := fill_rect.size.y * 0.32
	var shadow_height := fill_rect.size.y * 0.22
	draw_rect(Rect2(fill_rect.position + Vector2(1.0, 1.0), Vector2(max(fill_width - 2.0, 0.0), highlight_height)), fill_color.lightened(0.28))
	draw_rect(Rect2(fill_rect.position + Vector2(1.0, fill_rect.size.y - shadow_height - 1.0), Vector2(max(fill_width - 2.0, 0.0), shadow_height)), fill_color.darkened(0.22))
	
	var stripe_count := 5
	for i in range(stripe_count):
		var stripe_x := fill_rect.position.x + fill_width * float(i) / float(stripe_count)
		var stripe_width := fill_width / float(stripe_count * 2)
		var stripe_rect := Rect2(Vector2(stripe_x, fill_rect.position.y + 3.0), Vector2(stripe_width, max(fill_rect.size.y - 6.0, 0.0)))
		draw_rect(stripe_rect, fill_color.lightened(0.12 if i % 2 == 0 else 0.04))


func create_box(color: Color, radius: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.corner_radius_top_left = radius
	box.corner_radius_top_right = radius
	box.corner_radius_bottom_left = radius
	box.corner_radius_bottom_right = radius
	return box
