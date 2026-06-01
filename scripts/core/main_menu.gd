extends Control

const CartoonUiSkin = preload("res://scripts/ui/cartoon_ui_skin.gd")

@onready var tank_selector: OptionButton = $CenterContainer/VBoxContainer/TankSelector
@onready var tank_summary_label: Label = $CenterContainer/VBoxContainer/TankSummaryLabel
@onready var title_label: Label = $CenterContainer/VBoxContainer/TitleLabel
@onready var tank_label: Label = $CenterContainer/VBoxContainer/TankLabel
@onready var play_button: Button = $CenterContainer/VBoxContainer/PlayButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton


func _ready() -> void:
	apply_visual_skin()
	populate_tank_selector()


func apply_visual_skin() -> void:
	CartoonUiSkin.apply_label_pop(title_label, Color(1.0, 0.84, 0.16, 1.0))
	CartoonUiSkin.apply_label_pop(tank_label, Color(0.76, 0.95, 1.0, 1.0))
	CartoonUiSkin.apply_label_pop(tank_summary_label, Color(0.94, 0.98, 1.0, 1.0))
	CartoonUiSkin.apply_option_button(tank_selector)
	CartoonUiSkin.apply_button(play_button, Color(0.16, 0.58, 0.32, 1.0))
	CartoonUiSkin.apply_button(quit_button, Color(0.58, 0.18, 0.24, 1.0))


func _on_play_button_pressed() -> void:
	get_run_config().start_new_run()
	get_tree().change_scene_to_file("res://scenes/core/main.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func populate_tank_selector() -> void:
	tank_selector.clear()
	var selected_index := 0
	var run_config = get_run_config()
	var unlock_manager = get_unlock_manager()
	var tank_archetypes: Array = run_config.tank_archetypes
	for i in range(tank_archetypes.size()):
		var tank: Dictionary = tank_archetypes[i]
		var is_unlocked: bool = unlock_manager.is_tank_unlocked(String(tank.id))
		var label: String = String(tank.name) if is_unlocked else "%s (Locked)" % String(tank.name)
		tank_selector.add_item(label)
		tank_selector.set_item_metadata(i, String(tank.id))
		tank_selector.set_item_disabled(i, not is_unlocked)
		if is_unlocked and String(tank.id) == String(run_config.selected_tank_id):
			selected_index = i
	
	tank_selector.select(selected_index)
	update_selected_tank(selected_index)


func update_selected_tank(index: int) -> void:
	var tank_id := String(tank_selector.get_item_metadata(index))
	var run_config = get_run_config()
	if not get_unlock_manager().is_tank_unlocked(tank_id):
		tank_selector.select(0)
		return
	run_config.set_selected_tank(tank_id)
	var tank: Dictionary = run_config.get_selected_tank()
	tank_summary_label.text = String(tank.summary)


func _on_tank_selector_item_selected(index: int) -> void:
	update_selected_tank(index)


func get_run_config() -> Node:
	return get_node("/root/RunConfig")


func get_unlock_manager() -> Node:
	return get_node("/root/UnlockManager")
