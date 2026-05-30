extends Control

const AI_MENU_VIEW_DELAY: float = 0.5
const AI_SELECTION_FLASH_DELAY: float = 0.5
const AI_SELECTION_FLASH_COLOR: Color = Color(1.0, 0.95, 0.25, 1.0)

var player: CharacterBody2D
var ai_pick_in_progress: bool = false

@onready var ability_buttons: Array[Button] = [
	$CanvasLayer/ColorRect/MarginContainer/VBoxContainer/LandmineButton,
	$CanvasLayer/ColorRect/MarginContainer/VBoxContainer/CircularSawButton,
	$CanvasLayer/ColorRect/MarginContainer/VBoxContainer/FootsoldierButton,
]


func _on_landmine_button_pressed() -> void:
	if player and player.has_method("upgrade_landmine"):
		player.upgrade_landmine()
	complete_selection()


func _on_circular_saw_button_pressed() -> void:
	if player and player.has_method("upgrade_circular_saw"):
		player.upgrade_circular_saw()
	complete_selection()


func _on_footsoldier_button_pressed() -> void:
	if player and player.has_method("upgrade_footsoldier"):
		player.upgrade_footsoldier()
	complete_selection()


func complete_selection() -> void:
	if player and player.has_method("complete_ability_selection"):
		player.complete_ability_selection()
	
	queue_free()


func pick_random_ability() -> void:
	if ai_pick_in_progress:
		return
	
	ai_pick_in_progress = true
	var ability_methods: Array[String] = [
		"_on_landmine_button_pressed",
		"_on_circular_saw_button_pressed",
		"_on_footsoldier_button_pressed",
	]
	var slot_index: int = randi_range(0, ability_methods.size() - 1)
	await get_tree().create_timer(AI_MENU_VIEW_DELAY, true, false, true).timeout
	if not is_inside_tree():
		return
	highlight_ai_selection(slot_index)
	await get_tree().create_timer(AI_SELECTION_FLASH_DELAY, true, false, true).timeout
	if not is_inside_tree():
		return
	call(ability_methods[slot_index])


func highlight_ai_selection(slot_index: int) -> void:
	for button in ability_buttons:
		button.disabled = true
	
	if slot_index >= ability_buttons.size():
		return
	
	var selected_button: Button = ability_buttons[slot_index]
	var selected_style := StyleBoxFlat.new()
	selected_style.bg_color = AI_SELECTION_FLASH_COLOR
	selected_style.border_color = Color(1.0, 1.0, 1.0, 1.0)
	selected_style.set_border_width_all(3)
	selected_button.add_theme_stylebox_override("normal", selected_style)
	selected_button.add_theme_stylebox_override("disabled", selected_style)
	selected_button.text = "%s  [AI]" % selected_button.text
