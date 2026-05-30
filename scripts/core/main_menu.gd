extends Control

@onready var tank_selector: OptionButton = $CenterContainer/VBoxContainer/TankSelector
@onready var tank_summary_label: Label = $CenterContainer/VBoxContainer/TankSummaryLabel


func _ready() -> void:
	populate_tank_selector()


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/core/main.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func populate_tank_selector() -> void:
	tank_selector.clear()
	var selected_index := 0
	var run_config = get_run_config()
	var tank_archetypes: Array = run_config.tank_archetypes
	for i in range(tank_archetypes.size()):
		var tank: Dictionary = tank_archetypes[i]
		tank_selector.add_item(String(tank.name))
		tank_selector.set_item_metadata(i, String(tank.id))
		if String(tank.id) == String(run_config.selected_tank_id):
			selected_index = i
	
	tank_selector.select(selected_index)
	update_selected_tank(selected_index)


func update_selected_tank(index: int) -> void:
	var tank_id := String(tank_selector.get_item_metadata(index))
	var run_config = get_run_config()
	run_config.set_selected_tank(tank_id)
	var tank: Dictionary = run_config.get_selected_tank()
	tank_summary_label.text = String(tank.summary)


func _on_tank_selector_item_selected(index: int) -> void:
	update_selected_tank(index)


func get_run_config() -> Node:
	return get_node("/root/RunConfig")
