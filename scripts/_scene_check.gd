extends SceneTree

const RunModifierCatalog = preload("res://scripts/core/run_modifier_catalog.gd")
const RunEventCatalog = preload("res://scripts/core/run_event_catalog.gd")
const AutonomousTankCatalog = preload("res://scripts/core/autonomous_tank_catalog.gd")
const AutonomousMapCatalog = preload("res://scripts/core/autonomous_map_catalog.gd")
const LateMapEnemyCatalog = preload("res://scripts/core/late_map_enemy_catalog.gd")
const LateMapBossCatalog = preload("res://scripts/core/late_map_boss_catalog.gd")
const UnlockManagerScript = preload("res://scripts/core/unlock_manager.gd")


func _init() -> void:
	if not validate_branding_assets():
		return
	if not validate_progression_catalogs():
		return
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

		if scene_path == "res://scenes/core/main.tscn":
			var map_layout = instance.get_node_or_null("MapLayout")
			if map_layout == null:
				push_error("Main scene needs a MapLayout node.")
				quit(1)
				return
			map_layout.obstacle_root = map_layout
			for map_id in ["map1", "map2", "map3", "map4", "map5", "map6", "map7", "map8", "map9", "map10", "map11", "map12", "map13", "map14"]:
				map_layout.apply_map(map_id)
				if not map_layout.is_walkable(map_layout.arena_center, 0.0) and map_id != "map5":
					push_error("Map center should be walkable for %s." % map_id)
					quit(1)
					return
				if map_id != "map1" and map_layout.active_obstacle_rects.is_empty():
					push_error("%s needs authored obstacle collision cached by MapLayout." % map_id)
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


func validate_progression_catalogs() -> bool:
	if not validate_run_event_catalog():
		return false
	if not validate_autonomous_tank_catalog():
		return false
	if not validate_autonomous_map_catalog():
		return false
	if not validate_late_map_texture_catalogs():
		return false
	var modifier_ids: Array[String] = []
	for modifier in RunModifierCatalog.get_entries():
		modifier_ids.append(String(modifier.id))
	for required_modifier_id in ["singularity_seed", "clockwork_dividend", "quantum_current", "solar_furnace"]:
		if modifier_ids.has(required_modifier_id):
			continue
		push_error("Run modifier catalog should include %s." % required_modifier_id)
		quit(1)
		return false

	var unlock_manager = UnlockManagerScript.new()
	var unlocked_messages: Array[String] = []
	unlock_manager.unlocked_maps.append("map8")
	unlock_manager.ensure_map_tank_unlocks()
	if not unlock_manager.unlocked_tanks.has("neon_courier"):
		unlock_manager.free()
		push_error("Map 8 access should backfill Neon Courier.")
		quit(1)
		return false
	unlock_manager.record_completed_victory_map({"victory": true, "map_id": "map11"})
	unlock_manager.add_unlocks_for_victory({"victory": true, "map_id": "map11"}, unlocked_messages)
	if not unlock_manager.completed_victory_maps.has("map11"):
		unlock_manager.free()
		push_error("Map 11 victory should be persisted as a completed victory map.")
		quit(1)
		return false
	if not unlock_manager.unlocked_maps.has("map12"):
		unlock_manager.free()
		push_error("Map 11 victory should unlock Clockwork Spiral.")
		quit(1)
		return false
	if not unlock_manager.unlocked_modifiers.has("singularity_seed"):
		unlock_manager.free()
		push_error("Map 11 victory should unlock Singularity Seed.")
		quit(1)
		return false
	if not unlock_manager.unlocked_tanks.has("bloom_artillerist"):
		unlock_manager.free()
		push_error("Map 11 victory should unlock Bloom Artillerist.")
		quit(1)
		return false
	unlock_manager.record_completed_victory_map({"victory": true, "map_id": "map12"})
	unlock_manager.add_unlocks_for_victory({"victory": true, "map_id": "map12"}, unlocked_messages)
	if not unlock_manager.unlocked_modifiers.has("clockwork_dividend"):
		unlock_manager.free()
		push_error("Map 12 victory should unlock Clockwork Dividend.")
		quit(1)
		return false
	if not unlock_manager.unlocked_maps.has("map13"):
		unlock_manager.free()
		push_error("Map 12 victory should unlock Quantum Reef.")
		quit(1)
		return false
	if not unlock_manager.unlocked_tanks.has("gear_oracle"):
		unlock_manager.free()
		push_error("Map 12 victory should unlock Gear Oracle.")
		quit(1)
		return false
	unlock_manager.record_completed_victory_map({"victory": true, "map_id": "map13"})
	unlock_manager.add_unlocks_for_victory({"victory": true, "map_id": "map13"}, unlocked_messages)
	if not unlock_manager.unlocked_modifiers.has("quantum_current"):
		unlock_manager.free()
		push_error("Map 13 victory should unlock Quantum Current.")
		quit(1)
		return false
	if not unlock_manager.unlocked_maps.has("map14"):
		unlock_manager.free()
		push_error("Map 13 victory should unlock Solar Bastion.")
		quit(1)
		return false
	if not unlock_manager.unlocked_tanks.has("reef_savant"):
		unlock_manager.free()
		push_error("Map 13 victory should unlock Reef Savant.")
		quit(1)
		return false
	unlock_manager.record_completed_victory_map({"victory": true, "map_id": "map14"})
	unlock_manager.add_unlocks_for_victory({"victory": true, "map_id": "map14"}, unlocked_messages)
	if not unlock_manager.unlocked_modifiers.has("solar_furnace"):
		unlock_manager.free()
		push_error("Map 14 victory should unlock Solar Furnace.")
		quit(1)
		return false
	if not unlock_manager.unlocked_tanks.has("helio_bastion"):
		unlock_manager.free()
		push_error("Map 14 victory should unlock Helio Bastion.")
		quit(1)
		return false
	unlock_manager.free()
	return true


func validate_branding_assets() -> bool:
	if String(ProjectSettings.get_setting("application/config/name", "")) != "Autonomous Survivor":
		push_error("Project name should be Autonomous Survivor.")
		quit(1)
		return false
	var required_branding_assets: Array[String] = [
		"res://assets/ui/branding/app_icon_1024.png",
		"res://assets/ui/branding/app_icon_512.png",
		"res://assets/ui/branding/app_icon_256.png",
		"res://assets/ui/branding/app_icon_128.png",
		"res://assets/ui/branding/app_icon_64.png",
		"res://assets/ui/branding/app_icon_32.png",
		"res://assets/ui/branding/app_icon.ico",
		"res://assets/ui/branding/brand_mark_autonomous_survivor.png",
		"res://assets/ui/branding/logo_autonomous_survivor.png",
		"res://assets/ui/branding/wordmark_autonomous_survivor.png",
		"res://assets/ui/branding/icon_menu_play.png",
		"res://assets/ui/branding/icon_menu_compendium.png",
		"res://assets/ui/branding/icon_menu_quit.png",
	]
	for asset_path in required_branding_assets:
		if not FileAccess.file_exists(asset_path):
			push_error("Missing branding asset: %s" % asset_path)
			quit(1)
			return false
	if String(ProjectSettings.get_setting("application/boot_splash/image", "")) != "res://assets/ui/branding/logo_autonomous_survivor.png":
		push_error("Boot splash should use the Autonomous Survivor logo.")
		quit(1)
		return false
	if String(ProjectSettings.get_setting("application/config/icon", "")) != "res://assets/ui/branding/app_icon_1024.png":
		push_error("Project icon should use the Autonomous Survivor app icon.")
		quit(1)
		return false
	if String(ProjectSettings.get_setting("application/config/windows_native_icon", "")) != "res://assets/ui/branding/app_icon.ico":
		push_error("Windows native icon should use the generated Autonomous Survivor ico.")
		quit(1)
		return false
	return true


func validate_autonomous_map_catalog() -> bool:
	var seen_ids: Array[String] = []
	for map_config in AutonomousMapCatalog.get_entries():
		var map_id := String(map_config.get("id", ""))
		if map_id.is_empty() or seen_ids.has(map_id):
			push_error("Autonomous map catalog needs unique non-empty ids.")
			quit(1)
			return false
		seen_ids.append(map_id)
		if String(map_config.get("name", "")).is_empty():
			push_error("Autonomous map %s needs a display name." % map_id)
			quit(1)
			return false
		var background_texture := String(map_config.get("background_texture", ""))
		if background_texture != "" and not ResourceLoader.exists(background_texture):
			push_error("Autonomous map %s references missing background texture %s." % [map_id, background_texture])
			quit(1)
			return false
	for required_map_id in ["map13", "map14"]:
		if seen_ids.has(required_map_id):
			continue
		push_error("Autonomous map catalog should include %s." % required_map_id)
		quit(1)
		return false
	return true


func validate_late_map_texture_catalogs() -> bool:
	var enemy_scene := load("res://scenes/enemies/enemy.tscn") as PackedScene
	var brown_enemy_scene := load("res://scenes/enemies/brown_enemy.tscn") as PackedScene
	var shielded_enemy_scene := load("res://scenes/enemies/shielded_enemy.tscn") as PackedScene
	var boss_scene := load("res://scenes/enemies/boss_enemy.tscn") as PackedScene
	var map14_enemy_count := 0
	for enemy_config in LateMapEnemyCatalog.get_entries(enemy_scene, brown_enemy_scene, shielded_enemy_scene):
		if not validate_optional_texture_path(enemy_config, "Late enemy"):
			return false
		if (enemy_config.get("maps", []) as Array).has("map14"):
			map14_enemy_count += 1
	if map14_enemy_count < 5:
		push_error("Map 14 needs at least 5 map-specific late enemy entries.")
		quit(1)
		return false
	var map14_boss_count := 0
	for boss_config in LateMapBossCatalog.get_entries(boss_scene):
		if not validate_optional_texture_path(boss_config, "Late boss"):
			return false
		if (boss_config.get("maps", []) as Array).has("map14"):
			map14_boss_count += 1
	if map14_boss_count < 2:
		push_error("Map 14 needs at least 2 map-specific boss entries.")
		quit(1)
		return false
	return true


func validate_optional_texture_path(config: Dictionary, label: String) -> bool:
	var texture_path := String(config.get("texture", ""))
	if texture_path == "" or ResourceLoader.exists(texture_path):
		return true
	push_error("%s %s references missing texture %s." % [label, String(config.get("id", "")), texture_path])
	quit(1)
	return false


func validate_autonomous_tank_catalog() -> bool:
	var seen_ids: Array[String] = []
	var supported_passive_power_ids: Array[String] = [
		"vampire_circuit", "ion_lance", "meteor_shell", "bulldozer_aura", "supply_beacon",
		"black_hole_mines", "pulse_drone", "acid_pool", "guardian_wall", "critical_storm",
		"repair_burst", "magnet_storm", "orbital_cannon", "ember_turret", "time_shock",
		"phase_magnet", "munition_swarm", "fortress_protocol", "storm_catalyst", "golden_reactor",
	]
	for tank in AutonomousTankCatalog.get_entries():
		var tank_id := String(tank.get("id", ""))
		if tank_id.is_empty() or seen_ids.has(tank_id):
			push_error("Autonomous tank catalog needs unique non-empty ids.")
			quit(1)
			return false
		seen_ids.append(tank_id)
		if String(tank.get("name", "")).is_empty():
			push_error("Autonomous tank %s needs a display name." % tank_id)
			quit(1)
			return false
		if String(tank.get("summary", "")).is_empty():
			push_error("Autonomous tank %s needs a summary for the tank selector." % tank_id)
			quit(1)
			return false
		var passive_powers: Dictionary = tank.get("passive_powers", {}) as Dictionary
		for power_id in passive_powers:
			if supported_passive_power_ids.has(String(power_id)):
				continue
			push_error("Autonomous tank %s references unsupported passive power %s." % [tank_id, String(power_id)])
			quit(1)
			return false
	for required_tank_id in ["neon_courier", "bloom_artillerist", "gear_oracle", "reef_savant", "helio_bastion"]:
		if not seen_ids.has(required_tank_id):
			push_error("Autonomous tank catalog should include %s." % required_tank_id)
			quit(1)
			return false
	return true


func validate_run_event_catalog() -> bool:
	var supported_effect_keys: Array[String] = ["exp_value_multiplier", "enemy_damage_multiplier", "spawn_interval_multiplier", "enemy_speed_multiplier"]
	var supported_risk_keys: Array[String] = ["elite_wave_count"]
	var supported_reward_keys: Array[String] = ["green_supply", "blue_supply", "upgrade_choices", "ability_choices"]
	var seen_ids: Array[String] = []
	for event in RunEventCatalog.get_entries():
		var event_id := String(event.get("id", ""))
		if event_id.is_empty() or seen_ids.has(event_id):
			push_error("Run event catalog needs unique non-empty ids.")
			quit(1)
			return false
		seen_ids.append(event_id)
		if float(event.get("weight", 0.0)) <= 0.0:
			push_error("Run event %s needs positive weight." % event_id)
			quit(1)
			return false
		for key in (event.get("effects", {}) as Dictionary).keys():
			if not supported_effect_keys.has(String(key)):
				push_error("Run event %s uses unsupported effect key %s." % [event_id, String(key)])
				quit(1)
				return false
		for key in (event.get("risks", {}) as Dictionary).keys():
			if not supported_risk_keys.has(String(key)):
				push_error("Run event %s uses unsupported risk key %s." % [event_id, String(key)])
				quit(1)
				return false
		for key in (event.get("rewards", {}) as Dictionary).keys():
			if not supported_reward_keys.has(String(key)):
				push_error("Run event %s uses unsupported reward key %s." % [event_id, String(key)])
				quit(1)
				return false
	if seen_ids.size() < 15:
		push_error("Run event catalog should keep at least 15 events for replay variety.")
		quit(1)
		return false
	return true
