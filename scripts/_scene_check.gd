extends SceneTree


func _init() -> void:
	var scene_paths: Array[String] = [
		"res://scenes/core/main_menu.tscn",
		"res://scenes/core/main.tscn",
		"res://scenes/player/player.tscn",
		"res://scenes/enemies/enemy.tscn",
		"res://scenes/enemies/brown_enemy.tscn",
		"res://scenes/enemies/shielded_enemy.tscn",
		"res://scenes/enemies/boss_enemy.tscn",
		"res://scenes/abilities/shock_field.tscn",
		"res://scenes/abilities/artillery_beacon.tscn",
		"res://scenes/abilities/drone_swarm.tscn",
		"res://scenes/abilities/oil_slick.tscn",
		"res://scenes/abilities/oil_slick_dispenser.tscn",
		"res://scenes/abilities/freeze_pulse.tscn",
		"res://scenes/abilities/chain_lightning.tscn",
		"res://scenes/abilities/guardian_satellite.tscn",
		"res://scenes/abilities/overdrive_core.tscn",
		"res://scenes/abilities/flame_wave.tscn",
		"res://scenes/abilities/repair_beacon.tscn",
		"res://scenes/abilities/missile_pod.tscn",
		"res://scenes/abilities/gravity_well.tscn",
		"res://scenes/abilities/railgun_orbiter.tscn",
		"res://scenes/abilities/tesla_pylon.tscn",
		"res://scenes/abilities/nanite_cloud.tscn",
		"res://scenes/abilities/ricochet_rounds.tscn",
		"res://scenes/abilities/chrono_burst.tscn",
		"res://scenes/effects/boss_hazard.tscn",
		"res://scenes/ui/upgrade.tscn",
		"res://scenes/ui/ability_menu.tscn",
	]
	
	for scene_path in scene_paths:
		var packed_scene := load(scene_path) as PackedScene
		if packed_scene == null:
			push_error("Could not load scene: %s" % scene_path)
			quit(1)
			return
		
		var instance := packed_scene.instantiate()
		if instance == null:
			push_error("Could not instantiate scene: %s" % scene_path)
			quit(1)
			return

		if scene_path == "res://scenes/core/main.tscn" and instance.process_mode == Node.PROCESS_MODE_ALWAYS:
			push_error("Main scene must stay pausable; use focused always-processing helpers for paused input.")
			quit(1)
			return

		if scene_path == "res://scenes/ui/upgrade.tscn":
			if instance.get_node_or_null("CanvasLayer/ColorRect/MarginContainer/VBoxContainer/OptionsRow/OptionButton1/Icon") == null:
				push_error("Upgrade menu cards need owned icon nodes, not stretched button icons.")
				quit(1)
				return

		if scene_path == "res://scenes/ui/ability_menu.tscn":
			if instance.get_node_or_null("CanvasLayer/ColorRect/MarginContainer/VBoxContainer/OptionsRow/AbilityButton1/Icon") == null:
				push_error("Ability menu should use horizontal card icons.")
				quit(1)
				return

		if scene_path == "res://scenes/enemies/boss_enemy.tscn":
			instance.configure_variant({
				"phase_thresholds": [0.65, 0.32],
				"ability_modules": [
					{"type": "hazard_ring", "cooldown": 7.2},
					{"type": "minion_call", "cooldown": 11.0},
				],
			})
			if instance.phase_thresholds.size() != 2 or instance.ability_modules.size() != 2:
				push_error("Boss variant config did not preserve typed arrays.")
				quit(1)
				return
		
		instance.queue_free()
	
	print("Scene check passed.")
	quit()
