extends Node2D

var radius: float = 3.0
var lifetime: float = 0.16
var age: float = 0.0
var damaged_enemies := {}


func configure(splash_radius: float, damage: float, enemies: Array[Area2D], show_damage_numbers: bool = true) -> void:
	radius = splash_radius
	apply_damage(damage, enemies, show_damage_numbers)


func apply_damage(damage: float, enemies: Array[Area2D], show_damage_numbers: bool) -> void:
	if enemies.is_empty():
		return
	
	var reduction: float = max(1.0 - float(enemies.size()) * 0.1, 0.5)
	var splash_damage: float = damage * reduction
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		if damaged_enemies.has(enemy):
			continue
		if not enemy.is_inside_tree():
			continue
		if not enemy.has_method("hit"):
			continue
		
		damaged_enemies[enemy] = true
		var actual_damage: int = enemy.hit(splash_damage, show_damage_numbers)
		record_player_damage(actual_damage)


func record_player_damage(amount: int) -> void:
	if amount <= 0:
		return
	
	var main := get_tree().current_scene
	if main and main.has_method("record_player_damage"):
		main.record_player_damage(amount)


func _process(delta: float) -> void:
	age += delta
	if age >= lifetime:
		queue_free()
		return
	
	queue_redraw()


func _draw() -> void:
	var progress: float = clamp(age / lifetime, 0.0, 1.0)
	var current_radius: float = lerp(2.0, radius, ease(progress, -1.8))
	var alpha: float = 0.72 * (1.0 - progress)
	var ring_width: float = max(3.0, radius * 0.18 * (1.0 - progress * 0.35))
	var ring_color := Color(1.0, 0.48, 0.03, alpha)
	var highlight_color := Color(1.0, 0.86, 0.16, alpha * 0.65)
	var smoke_color := Color(0.07, 0.04, 0.03, alpha * 0.22)
	var flash_color := Color(1.0, 0.92, 0.32, alpha * 0.16)
	
	draw_circle(Vector2.ZERO, current_radius * 0.78, flash_color)
	draw_arc(Vector2.ZERO, current_radius + ring_width * 0.32, 0.0, TAU, 96, Color(0.02, 0.015, 0.01, alpha * 0.95), ring_width * 0.42, true)
	draw_arc(Vector2.ZERO, current_radius, 0.0, TAU, 96, ring_color, ring_width, true)
	draw_arc(Vector2.ZERO, max(current_radius - ring_width * 0.55, 1.0), 0.0, TAU, 96, highlight_color, max(ring_width * 0.35, 1.0), true)
	for i in range(8):
		var angle := TAU * float(i) / 8.0 + progress * 0.7
		var start := Vector2.RIGHT.rotated(angle) * current_radius * 0.25
		var end := Vector2.RIGHT.rotated(angle) * current_radius * 0.92
		draw_line(start, end, smoke_color, max(2.0, ring_width * 0.18), true)
