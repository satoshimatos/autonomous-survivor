extends RefCounted


static func get_entries() -> Array[Dictionary]:
	return [
	{
		"id": "shrapnel_core",
		"name": "Shrapnel Core",
		"requirements": {"damage": 4, "splash": 3, "piercing": 2},
		"effects": {"projectile_damage_multiplier": 1.2, "splash_radius_bonus": 18.0, "piercing_bonus": 2, "projectile_scale": 1.22},
	},
	{
		"id": "storm_armor",
		"name": "Storm Armor",
		"requirements": {"shock_field": 3, "barbed_wire": 3, "armor": 3},
		"effects": {"shock_field_level_bonus": 2, "barbed_wire_radius_bonus": 30.0, "barbed_wire_damage_multiplier": 1.35, "armor_reduction_bonus": 0.08},
	},
	{
		"id": "drone_foundry",
		"name": "Drone Foundry",
		"requirements": {"drone_swarm": 2, "cannon": 3, "fire_rate": 4},
		"effects": {"drone_swarm_level_bonus": 2, "cannon_projectile_bonus": 1, "projectile_damage_multiplier": 1.1, "projectile_scale": 1.12},
	},
	{
		"id": "critical_payload",
		"name": "Critical Payload",
		"requirements": {"targeting_array": 3, "payload_rack": 3, "damage": 4},
		"effects": {"crit_chance_bonus": 0.12, "crit_multiplier_bonus": 0.35, "splash_damage_multiplier": 1.2, "projectile_scale": 1.1},
	},
	{
		"id": "repair_loop",
		"name": "Repair Loop",
		"requirements": {"recycler": 3, "alloy_plating": 3, "reactive_shield": 2},
		"effects": {"recycler_heal_chance_bonus": 0.08, "armor_reduction_bonus": 0.05},
	},
	{
		"id": "storm_grid",
		"name": "Storm Grid",
		"requirements": {"chain_lightning": 3, "shock_field": 3, "freeze_pulse": 2},
		"effects": {"chain_lightning_level_bonus": 2, "shock_field_level_bonus": 1},
	},
	{
		"id": "guardian_protocol",
		"name": "Guardian Protocol",
		"requirements": {"guardian_satellite": 3, "overdrive_core": 3, "armor": 3},
		"effects": {"guardian_satellite_level_bonus": 2, "overdrive_damage_bonus": 0.12, "armor_reduction_bonus": 0.04},
	},
	{
		"id": "siege_command",
		"name": "Siege Command",
		"requirements": {"missile_pod": 3, "railgun_orbiter": 3, "targeting_array": 3},
		"effects": {"missile_pod_level_bonus": 2, "railgun_orbiter_level_bonus": 2, "projectile_damage_multiplier": 1.12},
	},
	{
		"id": "singularity_engine",
		"name": "Singularity Engine",
		"requirements": {"gravity_well": 3, "flame_wave": 3, "combustion_mix": 2},
		"effects": {"gravity_well_level_bonus": 2, "flame_wave_level_bonus": 2, "splash_damage_multiplier": 1.12},
	},
	{
		"id": "field_medic",
		"name": "Field Medic",
		"requirements": {"repair_beacon": 3, "nanobots": 3, "armor": 2},
		"effects": {"repair_beacon_level_bonus": 2, "armor_reduction_bonus": 0.03, "overdrive_damage_bonus": 0.04},
	},
	{
		"id": "coil_reactor",
		"name": "Coil Reactor",
		"requirements": {"volt_coils": 3, "capacitor_bank": 3, "chain_lightning": 3},
		"effects": {"chain_lightning_level_bonus": 2, "shock_field_level_bonus": 1, "overdrive_damage_bonus": 0.08},
	},
	{
		"id": "war_factory",
		"name": "War Factory",
		"requirements": {"ordnance_bay": 3, "missile_guidance": 3, "munition_printer": 3},
		"effects": {"missile_pod_level_bonus": 2, "cannon_projectile_bonus": 1, "splash_damage_multiplier": 1.14},
	},
	{
		"id": "recovery_swarm",
		"name": "Recovery Swarm",
		"requirements": {"repair_drones": 3, "repair_beacon": 3, "nanobots": 3},
		"effects": {"repair_beacon_level_bonus": 2, "heal_multiplier_bonus": 0.18, "armor_reduction_bonus": 0.03},
	},
	{
		"id": "death_orbit",
		"name": "Death Orbit",
		"requirements": {"orbit_gears": 3, "circular_saw": 3, "guardian_satellite": 3},
		"effects": {"guardian_satellite_level_bonus": 2, "barbed_wire_radius_bonus": 18.0, "power_contact_damage_bonus": 0.18},
	},
	{
		"id": "breach_rounds",
		"name": "Breach Rounds",
		"requirements": {"armor_piercers": 3, "weakpoint_scanner": 3, "railgun_orbiter": 2},
		"effects": {"railgun_orbiter_level_bonus": 2, "projectile_damage_multiplier": 1.16, "crit_multiplier_bonus": 0.25},
	},
	{
		"id": "time_cage",
		"name": "Time Cage",
		"requirements": {"chrono_burst": 3, "gravity_well": 3, "field_amplifier": 3},
		"effects": {"chrono_burst_level_bonus": 2, "gravity_well_level_bonus": 1, "splash_damage_multiplier": 1.1},
	},
	{
		"id": "storm_battery",
		"name": "Storm Battery",
		"requirements": {"tesla_pylon": 3, "volt_coils": 3, "chain_lightning": 3},
		"effects": {"tesla_pylon_level_bonus": 2, "chain_lightning_level_bonus": 1, "overdrive_damage_bonus": 0.08},
	},

	]
