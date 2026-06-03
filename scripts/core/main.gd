extends Node2D

const GamepadInputSetup = preload("res://scripts/core/gamepad_input_setup.gd")
const PauseInputRouter = preload("res://scripts/core/pause_input_router.gd")
const LateMapEnemyCatalog = preload("res://scripts/core/late_map_enemy_catalog.gd")

var player: CharacterBody2D
var pause_input_router: PauseInputRouter

var spawn_interval: float = 1.5
var spawn_timer: float = 0.0
var enemy_speed_scale: float = 1.0
var enemy_speed_scale_timer: float = 0.0
var enemy_health_scale_timer: float = 0.0
var enemy_health_bonus_step: float = 0.0
var enemy_health_bonus_total: float = 0.0
var enemy_damage_scale_timer: float = 0.0
var enemy_damage_multiplier: float = 1.0
var blue_orb_drop_chance: float = 1.0
var orange_orb_drop_chance: float = 0.0
var purple_orb_drop_chance: float = 0.0
var violet_orb_drop_chance: float = 0.0
var boss_spawn_timer: float = 0.0
var magnet_spawn_timer: float = 0.0
var supply_box_spawn_timer: float = 0.0
var magnet_effect_timer: float = 0.0
var run_time: float = 0.0
var dynamite_blast_active: bool = false
var splash_blast_active: bool = false
var queued_exp_drops: Array[Dictionary] = []
var magnet_pickup_pool
var dynamite_pickup_pool
var wrench_pickup_pool: Array[Node] = []
var projectile_pool: Array[Node] = []
var particle_burst_pool: Array[Node] = []
var active_enemies: Array[Node] = []
var active_bosses: Array[Node] = []
var active_exp_orbs: Array[Node] = []
var active_projectiles: Array[Node] = []
var active_particle_bursts: Array[Node] = []
var active_splash_areas: Array[Node] = []
var active_boss_hazards: Array[Node] = []
var is_player_paused: bool = false
var enemies_defeated: int = 0
var bosses_defeated: int = 0
var elites_defeated: int = 0
var spawn_skips_from_pressure: int = 0
var total_damage_dealt: int = 0
var total_damage_taken: int = 0
var debug_time_scale_index: int = 0
var is_startup_loading: bool = true
var player_damage_events: Array[Dictionary] = []
var player_dps: float = 0.0
var low_health_upgrade_timer: float = 0.0
var run_seed_text: String = ""
var run_modifier_summary: String = ""
var damage_numbers_this_frame: int = 0
var enemy_speed_growth_multiplier: float = 1.0
var enemy_health_growth_multiplier: float = 1.0
var enemy_damage_growth_multiplier: float = 1.0
var exp_value_multiplier: float = 1.0
var boss_exp_multiplier: float = 1.0
var boss_spawn_interval: float = 420.0
var supply_box_spawn_interval: float = 15.0
var supply_box_spawn_chance: float = 0.05
var wrench_drop_chance: float = 0.05
var dynamite_drop_chance: float = 0.001
var run_event_schedule: Array[Dictionary] = []
var next_run_event_index: int = 0
var active_run_events: Array[Dictionary] = []
var completed_run_event_names: Array[String] = []
var last_boss_variant_id: String = ""
var selected_map_name: String = "Dust Bowl"
var selected_map_id: String = "map1"
var active_enemy_cap_bonus: int = 0
var active_enemy_cap_limit: int = MAX_ACTIVE_ENEMY_CAP
var elite_chance_multiplier: float = 1.0
var map_gimmick: String = ""
var map_gimmick_interval: float = 0.0
var map_gimmick_timer: float = 0.0
var run_completed: bool = false
var run_was_victory: bool = false
var projectile_hit_feedback_this_frame: int = 0

const ENEMY = preload("uid://kxdifr4760x4")
const BROWN_ENEMY = preload("res://scenes/enemies/brown_enemy.tscn")
const SHIELDED_ENEMY = preload("res://scenes/enemies/shielded_enemy.tscn")
const BOSS_ENEMY = preload("res://scenes/enemies/boss_enemy.tscn")
const EXP_ORB = preload("res://scenes/pickups/exp_orb.tscn")
const MAGNET_PICKUP = preload("res://scenes/pickups/magnet_pickup.tscn")
const DYNAMITE_PICKUP = preload("res://scenes/pickups/dynamite_pickup.tscn")
const WRENCH_PICKUP = preload("res://scenes/pickups/wrench_pickup.tscn")
const SUPPLY_BOX_BLUE = preload("res://scenes/pickups/supply_box_blue.tscn")
const SUPPLY_BOX_GREEN = preload("res://scenes/pickups/supply_box_green.tscn")
const PARTICLE_BURST = preload("res://scenes/effects/particle_burst.tscn")
const SPLASH_AREA = preload("res://scenes/effects/splash_area.tscn")
const BOSS_HAZARD = preload("res://scenes/effects/boss_hazard.tscn")
const HEALING_POPUP = preload("res://scenes/effects/healing_popup.tscn")
const GREEN_EXP_CRYSTAL = preload("res://assets/exp/exp_crystal_green.png")
const BLUE_EXP_CRYSTAL = preload("res://assets/exp/exp_crystal_blue.png")
const RED_EXP_CRYSTAL = preload("res://assets/exp/exp_crystal_red.png")
const PURPLE_EXP_CRYSTAL = preload("res://assets/exp/exp_crystal_purple.png")
const PROJECTILE = preload("res://scenes/projectiles/projectile.tscn")
const LANDMINE = preload("res://scenes/abilities/landmine.tscn")
const CIRCULAR_SAW = preload("res://scenes/abilities/circular_saw.tscn")
const FOOTSOLDIER = preload("res://scenes/abilities/footsoldier.tscn")
const SHOCK_FIELD = preload("res://scenes/abilities/shock_field.tscn")
const ARTILLERY_BEACON = preload("res://scenes/abilities/artillery_beacon.tscn")
const DRONE_SWARM = preload("res://scenes/abilities/drone_swarm.tscn")
const OIL_SLICK_DISPENSER = preload("res://scenes/abilities/oil_slick_dispenser.tscn")
const FREEZE_PULSE = preload("res://scenes/abilities/freeze_pulse.tscn")
const UPGRADE_MENU = preload("res://scenes/ui/upgrade.tscn")
const ABILITY_MENU = preload("res://scenes/ui/ability_menu.tscn")

var enemy_variant_catalog: Array[Dictionary] = [
	{"id": "scout", "scene": ENEMY, "unlock_seconds": 0.0, "base_weight": 100.0, "growth_per_minute": -7.0, "min_weight": 4.0, "max_weight": 100.0, "health": 12, "speed": 58.0, "contact_damage": 1, "exp_drop_count": 1, "exp_drop_min_tier": 1, "color": Color(1.0, 0.08, 0.04, 1.0), "scale": 0.82, "movement_style": "chase"},
	{"id": "bruiser", "scene": BROWN_ENEMY, "unlock_seconds": 120.0, "base_weight": 20.0, "growth_per_minute": 1.8, "min_weight": 0.0, "max_weight": 34.0, "health": 22, "speed": 46.0, "contact_damage": 2, "exp_drop_count": 2, "exp_drop_min_tier": 1, "color": Color(0.5, 0.22, 0.08, 1.0), "scale": 1.08, "movement_style": "chase"},
	{"id": "runner", "scene": ENEMY, "unlock_seconds": 180.0, "base_weight": 20.0, "growth_per_minute": 1.8, "min_weight": 0.0, "max_weight": 36.0, "health": 10, "speed": 94.0, "contact_damage": 1, "exp_drop_count": 1, "exp_drop_min_tier": 1, "color": Color(1.0, 0.66, 0.05, 1.0), "scale": 0.72, "movement_style": "sprinter", "texture": "res://assets/visual/enemies/variants/enemy_runner_cartoon.png"},
	{"id": "shield", "scene": SHIELDED_ENEMY, "unlock_seconds": 240.0, "base_weight": 12.0, "growth_per_minute": 1.6, "min_weight": 0.0, "max_weight": 30.0, "health": 48, "speed": 27.0, "contact_damage": 3, "exp_drop_count": 3, "exp_drop_min_tier": 2, "color": Color(0.7, 0.72, 0.66, 1.0), "scale": 1.0, "movement_style": "chase"},
	{"id": "zigzag", "scene": ENEMY, "unlock_seconds": 300.0, "base_weight": 18.0, "growth_per_minute": 1.7, "min_weight": 0.0, "max_weight": 34.0, "health": 20, "speed": 68.0, "contact_damage": 2, "exp_drop_count": 2, "exp_drop_min_tier": 1, "color": Color(0.15, 0.8, 1.0, 1.0), "scale": 0.9, "movement_style": "zigzag", "texture": "res://assets/visual/enemies/variants/enemy_zigzag_cartoon.png"},
	{"id": "swarm", "scene": ENEMY, "unlock_seconds": 360.0, "base_weight": 26.0, "growth_per_minute": 2.2, "min_weight": 0.0, "max_weight": 48.0, "health": 8, "speed": 76.0, "contact_damage": 1, "exp_drop_count": 1, "exp_drop_min_tier": 1, "color": Color(1.0, 0.18, 0.38, 1.0), "scale": 0.58, "movement_style": "weaver", "texture": "res://assets/visual/enemies/variants/enemy_swarm_cartoon.png"},
	{"id": "stalker", "scene": ENEMY, "unlock_seconds": 480.0, "base_weight": 18.0, "growth_per_minute": 1.8, "min_weight": 0.0, "max_weight": 36.0, "health": 34, "speed": 54.0, "contact_damage": 3, "exp_drop_count": 3, "exp_drop_min_tier": 2, "color": Color(0.55, 0.1, 0.9, 1.0), "scale": 0.96, "movement_style": "stalker", "texture": "res://assets/visual/enemies/variants/enemy_stalker_cartoon.png"},
	{"id": "orbiter", "scene": ENEMY, "unlock_seconds": 600.0, "base_weight": 18.0, "growth_per_minute": 2.0, "min_weight": 0.0, "max_weight": 38.0, "health": 42, "speed": 62.0, "contact_damage": 3, "exp_drop_count": 3, "exp_drop_min_tier": 2, "color": Color(0.15, 1.0, 0.38, 1.0), "scale": 0.92, "movement_style": "orbiter", "texture": "res://assets/visual/enemies/variants/enemy_orbiter_cartoon.png"},
	{"id": "tank", "scene": SHIELDED_ENEMY, "unlock_seconds": 720.0, "base_weight": 10.0, "growth_per_minute": 1.2, "min_weight": 0.0, "max_weight": 22.0, "health": 86, "speed": 21.0, "contact_damage": 5, "exp_drop_count": 5, "exp_drop_min_tier": 3, "color": Color(0.2, 0.28, 0.3, 1.0), "scale": 1.22, "movement_style": "chase", "texture": "res://assets/visual/enemies/variants/enemy_tank_cartoon.png"},
	{"id": "drifter", "scene": ENEMY, "unlock_seconds": 840.0, "base_weight": 18.0, "growth_per_minute": 2.4, "min_weight": 0.0, "max_weight": 42.0, "health": 54, "speed": 70.0, "contact_damage": 4, "exp_drop_count": 4, "exp_drop_min_tier": 3, "color": Color(0.98, 0.92, 0.16, 1.0), "scale": 1.0, "movement_style": "drifter", "texture": "res://assets/visual/enemies/variants/enemy_drifter_cartoon.png"},
	{"id": "lancer", "scene": ENEMY, "unlock_seconds": 960.0, "base_weight": 16.0, "growth_per_minute": 1.8, "min_weight": 0.0, "max_weight": 36.0, "health": 46, "speed": 104.0, "contact_damage": 5, "exp_drop_count": 4, "exp_drop_min_tier": 3, "color": Color(1.0, 0.34, 0.0, 1.0), "scale": 0.76, "movement_style": "sprinter", "texture": "res://assets/visual/enemies/variants/enemy_runner_cartoon.png"},
	{"id": "phalanx", "scene": SHIELDED_ENEMY, "unlock_seconds": 1080.0, "base_weight": 12.0, "growth_per_minute": 1.4, "min_weight": 0.0, "max_weight": 28.0, "health": 128, "speed": 26.0, "contact_damage": 6, "exp_drop_count": 6, "exp_drop_min_tier": 3, "color": Color(0.48, 0.58, 0.68, 1.0), "scale": 1.34, "movement_style": "chase", "texture": "res://assets/visual/enemies/variants/enemy_tank_cartoon.png"},
	{"id": "mirage", "scene": ENEMY, "unlock_seconds": 1200.0, "base_weight": 20.0, "growth_per_minute": 2.1, "min_weight": 0.0, "max_weight": 42.0, "health": 32, "speed": 90.0, "contact_damage": 4, "exp_drop_count": 3, "exp_drop_min_tier": 3, "color": Color(0.18, 0.95, 0.95, 1.0), "scale": 0.64, "movement_style": "weaver", "texture": "res://assets/visual/enemies/variants/enemy_zigzag_cartoon.png"},
	{"id": "reaper", "scene": ENEMY, "unlock_seconds": 1440.0, "base_weight": 14.0, "growth_per_minute": 1.7, "min_weight": 0.0, "max_weight": 34.0, "health": 92, "speed": 64.0, "contact_damage": 7, "exp_drop_count": 7, "exp_drop_min_tier": 4, "color": Color(0.1, 0.9, 0.45, 1.0), "scale": 1.04, "movement_style": "stalker", "texture": "res://assets/visual/enemies/variants/enemy_reaper_cartoon.png"},
	{"id": "comet", "scene": ENEMY, "unlock_seconds": 1680.0, "base_weight": 18.0, "growth_per_minute": 2.0, "min_weight": 0.0, "max_weight": 40.0, "health": 72, "speed": 112.0, "contact_damage": 6, "exp_drop_count": 5, "exp_drop_min_tier": 4, "color": Color(1.0, 0.82, 0.18, 1.0), "scale": 0.82, "movement_style": "drifter", "texture": "res://assets/visual/enemies/variants/enemy_drifter_cartoon.png"},
	{"id": "viper", "scene": ENEMY, "unlock_seconds": 1860.0, "base_weight": 16.0, "growth_per_minute": 2.0, "min_weight": 0.0, "max_weight": 38.0, "health": 68, "speed": 118.0, "contact_damage": 7, "exp_drop_count": 5, "exp_drop_min_tier": 4, "color": Color(0.65, 1.0, 0.12, 1.0), "scale": 0.7, "movement_style": "zigzag", "texture": "res://assets/visual/enemies/variants/enemy_runner_cartoon.png"},
	{"id": "bulldozer", "scene": SHIELDED_ENEMY, "unlock_seconds": 1980.0, "base_weight": 10.0, "growth_per_minute": 1.2, "min_weight": 0.0, "max_weight": 26.0, "health": 180, "speed": 24.0, "contact_damage": 9, "exp_drop_count": 8, "exp_drop_min_tier": 4, "color": Color(0.32, 0.34, 0.38, 1.0), "scale": 1.52, "movement_style": "chase", "texture": "res://assets/visual/enemies/variants/enemy_tank_cartoon.png"},
	{"id": "specter", "scene": ENEMY, "unlock_seconds": 2100.0, "base_weight": 18.0, "growth_per_minute": 2.2, "min_weight": 0.0, "max_weight": 42.0, "health": 58, "speed": 98.0, "contact_damage": 6, "exp_drop_count": 5, "exp_drop_min_tier": 4, "color": Color(0.58, 0.38, 1.0, 1.0), "scale": 0.72, "movement_style": "orbiter", "texture": "res://assets/visual/enemies/variants/enemy_orbiter_cartoon.png"},
	{"id": "sapper", "scene": BROWN_ENEMY, "unlock_seconds": 2220.0, "base_weight": 14.0, "growth_per_minute": 1.8, "min_weight": 0.0, "max_weight": 34.0, "health": 76, "speed": 74.0, "contact_damage": 8, "exp_drop_count": 6, "exp_drop_min_tier": 4, "color": Color(1.0, 0.42, 0.18, 1.0), "scale": 0.95, "movement_style": "stalker", "texture": "res://assets/visual/enemies/variants/enemy_stalker_cartoon.png"},
	{"id": "voidling", "scene": ENEMY, "unlock_seconds": 2340.0, "base_weight": 20.0, "growth_per_minute": 2.4, "min_weight": 0.0, "max_weight": 44.0, "health": 88, "speed": 84.0, "contact_damage": 8, "exp_drop_count": 7, "exp_drop_min_tier": 4, "color": Color(0.22, 0.05, 0.42, 1.0), "scale": 0.86, "movement_style": "weaver", "texture": "res://assets/visual/enemies/variants/enemy_zigzag_cartoon.png"},
	{"id": "scrap_scout", "maps": ["map2"], "scene": ENEMY, "unlock_seconds": 0.0, "base_weight": 88.0, "growth_per_minute": -3.5, "min_weight": 18.0, "max_weight": 88.0, "health": 16, "speed": 74.0, "contact_damage": 1, "exp_drop_count": 1, "exp_drop_min_tier": 1, "color": Color(0.95, 0.5, 0.24, 1.0), "scale": 0.8, "movement_style": "zigzag", "texture": "res://assets/visual/enemies/map2/scrap_scout.png"},
	{"id": "gear_runner", "maps": ["map2"], "scene": ENEMY, "unlock_seconds": 90.0, "base_weight": 36.0, "growth_per_minute": 2.4, "min_weight": 0.0, "max_weight": 58.0, "health": 14, "speed": 116.0, "contact_damage": 2, "exp_drop_count": 1, "exp_drop_min_tier": 1, "color": Color(0.32, 0.85, 1.0, 1.0), "scale": 0.66, "movement_style": "sprinter", "texture": "res://assets/visual/enemies/map2/gear_runner.png"},
	{"id": "slag_brute", "maps": ["map2"], "scene": BROWN_ENEMY, "unlock_seconds": 210.0, "base_weight": 24.0, "growth_per_minute": 2.0, "min_weight": 0.0, "max_weight": 46.0, "health": 42, "speed": 48.0, "contact_damage": 4, "exp_drop_count": 3, "exp_drop_min_tier": 2, "color": Color(1.0, 0.28, 0.13, 1.0), "scale": 1.1, "movement_style": "chase", "texture": "res://assets/visual/enemies/map2/slag_brute.png"},
	{"id": "magnet_wraith", "maps": ["map2"], "scene": ENEMY, "unlock_seconds": 360.0, "base_weight": 28.0, "growth_per_minute": 2.8, "min_weight": 0.0, "max_weight": 54.0, "health": 32, "speed": 88.0, "contact_damage": 3, "exp_drop_count": 2, "exp_drop_min_tier": 2, "color": Color(0.65, 0.4, 1.0, 1.0), "scale": 0.78, "movement_style": "orbiter", "texture": "res://assets/visual/enemies/map2/magnet_wraith.png"},
	{"id": "crusher_drone", "maps": ["map2"], "scene": SHIELDED_ENEMY, "unlock_seconds": 540.0, "base_weight": 18.0, "growth_per_minute": 1.7, "min_weight": 0.0, "max_weight": 36.0, "health": 76, "speed": 36.0, "contact_damage": 5, "exp_drop_count": 4, "exp_drop_min_tier": 3, "color": Color(0.56, 0.62, 0.65, 1.0), "scale": 1.18, "movement_style": "drifter", "texture": "res://assets/visual/enemies/map2/crusher_drone.png"},
	{"id": "furnace_reaper", "maps": ["map2"], "scene": ENEMY, "unlock_seconds": 840.0, "base_weight": 16.0, "growth_per_minute": 2.1, "min_weight": 0.0, "max_weight": 38.0, "health": 108, "speed": 72.0, "contact_damage": 8, "exp_drop_count": 7, "exp_drop_min_tier": 4, "color": Color(1.0, 0.18, 0.05, 1.0), "scale": 1.05, "movement_style": "stalker", "texture": "res://assets/visual/enemies/map2/furnace_reaper.png"},
	{"id": "shardling", "maps": ["map3"], "scene": ENEMY, "unlock_seconds": 0.0, "base_weight": 92.0, "growth_per_minute": -3.0, "min_weight": 20.0, "max_weight": 92.0, "health": 24, "speed": 92.0, "contact_damage": 2, "exp_drop_count": 1, "exp_drop_min_tier": 1, "color": Color(0.38, 0.92, 1.0, 1.0), "scale": 0.68, "movement_style": "zigzag", "texture": "res://assets/visual/enemies/map3/shardling.png"},
	{"id": "prism_runner", "maps": ["map3"], "scene": ENEMY, "unlock_seconds": 120.0, "base_weight": 34.0, "growth_per_minute": 2.6, "min_weight": 0.0, "max_weight": 60.0, "health": 20, "speed": 132.0, "contact_damage": 3, "exp_drop_count": 2, "exp_drop_min_tier": 1, "color": Color(1.0, 0.48, 0.92, 1.0), "scale": 0.6, "movement_style": "sprinter", "texture": "res://assets/visual/enemies/map3/prism_runner.png"},
	{"id": "quartz_bulwark", "maps": ["map3"], "scene": SHIELDED_ENEMY, "unlock_seconds": 300.0, "base_weight": 22.0, "growth_per_minute": 1.8, "min_weight": 0.0, "max_weight": 42.0, "health": 92, "speed": 32.0, "contact_damage": 6, "exp_drop_count": 5, "exp_drop_min_tier": 3, "color": Color(0.72, 0.96, 1.0, 1.0), "scale": 1.18, "movement_style": "chase", "texture": "res://assets/visual/enemies/map3/quartz_bulwark.png"},
	{"id": "lens_wraith", "maps": ["map3"], "scene": ENEMY, "unlock_seconds": 540.0, "base_weight": 28.0, "growth_per_minute": 2.5, "min_weight": 0.0, "max_weight": 56.0, "health": 54, "speed": 98.0, "contact_damage": 5, "exp_drop_count": 4, "exp_drop_min_tier": 3, "color": Color(0.62, 0.62, 1.0, 1.0), "scale": 0.78, "movement_style": "orbiter", "texture": "res://assets/visual/enemies/map3/lens_wraith.png"},
	{"id": "crystal_juggernaut", "maps": ["map3"], "scene": SHIELDED_ENEMY, "unlock_seconds": 900.0, "base_weight": 16.0, "growth_per_minute": 1.6, "min_weight": 0.0, "max_weight": 34.0, "health": 180, "speed": 30.0, "contact_damage": 10, "exp_drop_count": 8, "exp_drop_min_tier": 4, "color": Color(0.3, 0.95, 1.0, 1.0), "scale": 1.42, "movement_style": "drifter", "texture": "res://assets/visual/enemies/map3/crystal_juggernaut.png"},
	{"id": "spore_tick", "maps": ["map4"], "scene": ENEMY, "unlock_seconds": 0.0, "base_weight": 96.0, "growth_per_minute": -2.2, "min_weight": 22.0, "max_weight": 96.0, "health": 34, "speed": 82.0, "contact_damage": 3, "exp_drop_count": 2, "exp_drop_min_tier": 1, "color": Color(0.55, 1.0, 0.16, 1.0), "scale": 0.72, "movement_style": "weaver", "texture": "res://assets/visual/enemies/map4/spore_tick.png"},
	{"id": "acid_sprinter", "maps": ["map4"], "scene": ENEMY, "unlock_seconds": 150.0, "base_weight": 36.0, "growth_per_minute": 2.3, "min_weight": 0.0, "max_weight": 62.0, "health": 32, "speed": 126.0, "contact_damage": 4, "exp_drop_count": 2, "exp_drop_min_tier": 2, "color": Color(0.82, 1.0, 0.18, 1.0), "scale": 0.66, "movement_style": "sprinter", "texture": "res://assets/visual/enemies/map4/acid_sprinter.png"},
	{"id": "caustic_bloater", "maps": ["map4"], "scene": BROWN_ENEMY, "unlock_seconds": 360.0, "base_weight": 28.0, "growth_per_minute": 2.1, "min_weight": 0.0, "max_weight": 50.0, "health": 140, "speed": 38.0, "contact_damage": 8, "exp_drop_count": 6, "exp_drop_min_tier": 3, "color": Color(0.5, 0.85, 0.18, 1.0), "scale": 1.26, "movement_style": "chase", "texture": "res://assets/visual/enemies/map4/caustic_bloater.png"},
	{"id": "fume_stalker", "maps": ["map4"], "scene": ENEMY, "unlock_seconds": 600.0, "base_weight": 30.0, "growth_per_minute": 2.8, "min_weight": 0.0, "max_weight": 58.0, "health": 72, "speed": 88.0, "contact_damage": 7, "exp_drop_count": 5, "exp_drop_min_tier": 3, "color": Color(0.38, 0.72, 0.22, 1.0), "scale": 0.9, "movement_style": "stalker", "texture": "res://assets/visual/enemies/map4/fume_stalker.png"},
	{"id": "slag_titan", "maps": ["map4"], "scene": SHIELDED_ENEMY, "unlock_seconds": 960.0, "base_weight": 18.0, "growth_per_minute": 1.8, "min_weight": 0.0, "max_weight": 38.0, "health": 260, "speed": 26.0, "contact_damage": 13, "exp_drop_count": 10, "exp_drop_min_tier": 4, "color": Color(0.72, 0.9, 0.2, 1.0), "scale": 1.58, "movement_style": "chase", "texture": "res://assets/visual/enemies/map4/slag_titan.png"},
	{"id": "null_mite", "maps": ["map5"], "scene": ENEMY, "unlock_seconds": 0.0, "base_weight": 110.0, "growth_per_minute": -1.8, "min_weight": 32.0, "max_weight": 110.0, "health": 44, "speed": 118.0, "contact_damage": 4, "exp_drop_count": 2, "exp_drop_min_tier": 2, "color": Color(0.78, 0.35, 1.0, 1.0), "scale": 0.58, "movement_style": "weaver", "texture": "res://assets/visual/enemies/map5/null_mite.png"},
	{"id": "rift_lancer", "maps": ["map5"], "scene": ENEMY, "unlock_seconds": 100.0, "base_weight": 40.0, "growth_per_minute": 3.0, "min_weight": 0.0, "max_weight": 72.0, "health": 48, "speed": 152.0, "contact_damage": 6, "exp_drop_count": 3, "exp_drop_min_tier": 2, "color": Color(1.0, 0.32, 0.86, 1.0), "scale": 0.62, "movement_style": "sprinter", "texture": "res://assets/visual/enemies/map5/rift_lancer.png"},
	{"id": "gravity_knight", "maps": ["map5"], "scene": SHIELDED_ENEMY, "unlock_seconds": 300.0, "base_weight": 28.0, "growth_per_minute": 2.3, "min_weight": 0.0, "max_weight": 54.0, "health": 150, "speed": 46.0, "contact_damage": 10, "exp_drop_count": 7, "exp_drop_min_tier": 3, "color": Color(0.42, 0.22, 0.86, 1.0), "scale": 1.14, "movement_style": "orbiter", "texture": "res://assets/visual/enemies/map5/gravity_knight.png"},
	{"id": "event_horizon", "maps": ["map5"], "scene": BROWN_ENEMY, "unlock_seconds": 620.0, "base_weight": 26.0, "growth_per_minute": 2.7, "min_weight": 0.0, "max_weight": 58.0, "health": 120, "speed": 78.0, "contact_damage": 9, "exp_drop_count": 6, "exp_drop_min_tier": 4, "color": Color(0.2, 0.08, 0.36, 1.0), "scale": 1.0, "movement_style": "stalker", "texture": "res://assets/visual/enemies/map5/event_horizon.png"},
	{"id": "cosmic_devourer", "maps": ["map5"], "scene": SHIELDED_ENEMY, "unlock_seconds": 980.0, "base_weight": 20.0, "growth_per_minute": 2.2, "min_weight": 0.0, "max_weight": 46.0, "health": 320, "speed": 34.0, "contact_damage": 16, "exp_drop_count": 12, "exp_drop_min_tier": 4, "color": Color(0.5, 0.16, 1.0, 1.0), "scale": 1.42, "movement_style": "drifter", "texture": "res://assets/visual/enemies/map5/cosmic_devourer.png"},
]

var boss_variant_catalog: Array[Dictionary] = [
	{"id": "charger", "scene": BOSS_ENEMY, "unlock_seconds": 0.0, "weight": 100.0, "growth_per_minute": -8.0, "min_weight": 20.0, "max_weight": 100.0, "health": 950, "speed": 25.0, "contact_damage": 5, "exp_drop_count": 30, "exp_drop_min_tier": 1, "color": Color(0.5, 0.05, 0.62, 1.0), "scale": 1.0, "behavior": "charger", "texture": "res://assets/visual/enemies/variants/enemy_stalker_cartoon.png"},
	{"id": "bulwark", "scene": BOSS_ENEMY, "unlock_seconds": 0.0, "weight": 55.0, "growth_per_minute": 1.0, "min_weight": 0.0, "max_weight": 70.0, "health": 1550, "speed": 17.0, "contact_damage": 8, "exp_drop_count": 38, "exp_drop_min_tier": 2, "color": Color(0.18, 0.45, 0.8, 1.0), "scale": 1.18, "behavior": "bulwark", "texture": "res://assets/visual/enemies/variants/enemy_tank_cartoon.png", "phase_thresholds": [0.55], "ability_modules": [{"type": "minion_call", "cooldown": 8.0, "initial_delay": 3.5, "count": 3, "phase_count_bonus": 2}]},
	{"id": "sprinter", "scene": BOSS_ENEMY, "unlock_seconds": 0.0, "weight": 55.0, "growth_per_minute": 1.5, "min_weight": 0.0, "max_weight": 75.0, "health": 1100, "speed": 34.0, "contact_damage": 6, "exp_drop_count": 42, "exp_drop_min_tier": 2, "color": Color(1.0, 0.38, 0.08, 1.0), "scale": 0.9, "behavior": "sprinter", "texture": "res://assets/visual/enemies/variants/enemy_runner_cartoon.png"},
	{"id": "crusher", "scene": BOSS_ENEMY, "unlock_seconds": 0.0, "weight": 62.0, "growth_per_minute": 1.2, "min_weight": 0.0, "max_weight": 82.0, "health": 2200, "speed": 15.0, "contact_damage": 11, "exp_drop_count": 52, "exp_drop_min_tier": 3, "color": Color(0.7, 0.08, 0.08, 1.0), "scale": 1.35, "behavior": "crusher", "texture": "res://assets/visual/enemies/variants/enemy_tank_cartoon.png", "phase_thresholds": [0.65, 0.32], "ability_modules": [{"type": "hazard_ring", "cooldown": 7.2, "initial_delay": 2.8, "count": 5, "phase_count_bonus": 2, "radius": 74.0, "ring_distance": 170.0, "damage": 3}]},
	{"id": "wraith", "scene": BOSS_ENEMY, "unlock_seconds": 0.0, "weight": 70.0, "growth_per_minute": 1.5, "min_weight": 0.0, "max_weight": 90.0, "health": 1750, "speed": 30.0, "contact_damage": 9, "exp_drop_count": 60, "exp_drop_min_tier": 4, "color": Color(0.72, 0.2, 1.0, 1.0), "scale": 1.02, "behavior": "wraith", "texture": "res://assets/visual/enemies/variants/enemy_orbiter_cartoon.png", "phase_thresholds": [0.5], "ability_modules": [{"type": "target_hazard", "cooldown": 5.6, "initial_delay": 2.2, "radius": 64.0, "damage": 3}, {"type": "minion_call", "cooldown": 11.0, "initial_delay": 5.0, "count": 2, "phase_count_bonus": 1}]},
	{"id": "monarch", "scene": BOSS_ENEMY, "unlock_seconds": 0.0, "weight": 64.0, "growth_per_minute": 1.4, "min_weight": 0.0, "max_weight": 86.0, "health": 2400, "speed": 22.0, "contact_damage": 10, "exp_drop_count": 68, "exp_drop_min_tier": 4, "color": Color(0.95, 0.68, 0.18, 1.0), "scale": 1.12, "behavior": "monarch", "texture": "res://assets/visual/enemies/variants/enemy_drifter_cartoon.png", "phase_thresholds": [0.66, 0.33], "ability_modules": [{"type": "minion_call", "cooldown": 7.5, "initial_delay": 2.0, "count": 4, "phase_count_bonus": 2}, {"type": "target_hazard", "cooldown": 8.5, "initial_delay": 4.5, "radius": 70.0, "damage": 4}]},
	{"id": "tempest", "scene": BOSS_ENEMY, "unlock_seconds": 0.0, "weight": 68.0, "growth_per_minute": 1.5, "min_weight": 0.0, "max_weight": 88.0, "health": 2050, "speed": 38.0, "contact_damage": 8, "exp_drop_count": 74, "exp_drop_min_tier": 4, "color": Color(0.15, 0.9, 1.0, 1.0), "scale": 0.94, "behavior": "tempest", "texture": "res://assets/visual/enemies/variants/enemy_zigzag_cartoon.png", "phase_thresholds": [0.72, 0.44, 0.2], "ability_modules": [{"type": "hazard_ring", "cooldown": 6.4, "initial_delay": 2.5, "count": 6, "phase_count_bonus": 1, "radius": 58.0, "ring_distance": 150.0, "damage": 3}, {"type": "target_hazard", "cooldown": 5.2, "initial_delay": 5.0, "radius": 52.0, "damage": 3}]},
	{"id": "bastion", "scene": BOSS_ENEMY, "unlock_seconds": 0.0, "weight": 72.0, "growth_per_minute": 1.2, "min_weight": 0.0, "max_weight": 92.0, "health": 3200, "speed": 13.0, "contact_damage": 14, "exp_drop_count": 84, "exp_drop_min_tier": 4, "color": Color(0.4, 0.44, 0.52, 1.0), "scale": 1.48, "behavior": "bastion", "texture": "res://assets/visual/enemies/variants/enemy_tank_cartoon.png", "phase_thresholds": [0.75, 0.5, 0.25], "ability_modules": [{"type": "hazard_ring", "cooldown": 7.0, "initial_delay": 2.8, "count": 7, "phase_count_bonus": 2, "radius": 82.0, "ring_distance": 190.0, "damage": 4}, {"type": "minion_call", "cooldown": 10.0, "initial_delay": 6.0, "count": 3, "phase_count_bonus": 2}]},
	{"id": "overlord", "scene": BOSS_ENEMY, "unlock_seconds": 0.0, "weight": 76.0, "growth_per_minute": 1.2, "min_weight": 0.0, "max_weight": 94.0, "health": 3600, "speed": 20.0, "contact_damage": 15, "exp_drop_count": 92, "exp_drop_min_tier": 4, "color": Color(0.9, 0.12, 0.35, 1.0), "scale": 1.28, "behavior": "overlord", "texture": "res://assets/visual/enemies/variants/enemy_reaper_cartoon.png", "phase_thresholds": [0.78, 0.55, 0.32, 0.16], "ability_modules": [{"type": "minion_call", "cooldown": 6.8, "initial_delay": 2.0, "count": 5, "phase_count_bonus": 1}, {"type": "hazard_ring", "cooldown": 8.0, "initial_delay": 4.0, "count": 8, "phase_count_bonus": 1, "radius": 70.0, "ring_distance": 210.0, "damage": 4}, {"type": "target_hazard", "cooldown": 6.2, "initial_delay": 6.0, "radius": 62.0, "damage": 4}]},
	{"id": "singularity", "scene": BOSS_ENEMY, "unlock_seconds": 0.0, "weight": 80.0, "growth_per_minute": 1.1, "min_weight": 0.0, "max_weight": 96.0, "health": 2950, "speed": 32.0, "contact_damage": 13, "exp_drop_count": 100, "exp_drop_min_tier": 4, "color": Color(0.18, 0.02, 0.32, 1.0), "scale": 1.08, "behavior": "singularity", "texture": "res://assets/visual/enemies/variants/enemy_zigzag_cartoon.png", "phase_thresholds": [0.7, 0.45, 0.22], "ability_modules": [{"type": "target_hazard", "cooldown": 4.8, "initial_delay": 1.8, "radius": 66.0, "damage": 5}, {"type": "hazard_ring", "cooldown": 6.2, "initial_delay": 3.2, "count": 9, "phase_count_bonus": 2, "radius": 56.0, "ring_distance": 145.0, "damage": 4}]},
	{"id": "scrapyard_warden", "maps": ["map2"], "scene": BOSS_ENEMY, "unlock_seconds": 0.0, "weight": 120.0, "growth_per_minute": -2.0, "min_weight": 64.0, "max_weight": 120.0, "health": 1850, "speed": 24.0, "contact_damage": 9, "exp_drop_count": 48, "exp_drop_min_tier": 3, "color": Color(0.95, 0.45, 0.12, 1.0), "scale": 1.14, "behavior": "crusher", "texture": "res://assets/visual/enemies/map2/boss_scrapyard_warden.png", "phase_thresholds": [0.68, 0.36], "ability_modules": [{"type": "hazard_ring", "cooldown": 6.0, "initial_delay": 2.0, "count": 6, "phase_count_bonus": 2, "radius": 62.0, "ring_distance": 155.0, "damage": 4}, {"type": "minion_call", "cooldown": 8.0, "initial_delay": 4.0, "count": 3, "phase_count_bonus": 2}]},
	{"id": "magnetar_colossus", "maps": ["map2"], "scene": BOSS_ENEMY, "unlock_seconds": 420.0, "weight": 82.0, "growth_per_minute": 1.8, "min_weight": 0.0, "max_weight": 108.0, "health": 2700, "speed": 28.0, "contact_damage": 12, "exp_drop_count": 72, "exp_drop_min_tier": 4, "color": Color(0.5, 0.22, 1.0, 1.0), "scale": 1.24, "behavior": "singularity", "texture": "res://assets/visual/enemies/map2/boss_magnetar_colossus.png", "phase_thresholds": [0.72, 0.48, 0.24], "ability_modules": [{"type": "target_hazard", "cooldown": 4.6, "initial_delay": 1.7, "radius": 68.0, "damage": 5}, {"type": "hazard_ring", "cooldown": 6.0, "initial_delay": 3.6, "count": 8, "phase_count_bonus": 1, "radius": 58.0, "ring_distance": 170.0, "damage": 4}]},
	{"id": "foundry_overlord", "maps": ["map2"], "scene": BOSS_ENEMY, "unlock_seconds": 900.0, "weight": 72.0, "growth_per_minute": 2.0, "min_weight": 0.0, "max_weight": 112.0, "health": 3800, "speed": 19.0, "contact_damage": 16, "exp_drop_count": 96, "exp_drop_min_tier": 4, "color": Color(1.0, 0.16, 0.08, 1.0), "scale": 1.42, "behavior": "overlord", "texture": "res://assets/visual/enemies/map2/boss_foundry_overlord.png", "phase_thresholds": [0.8, 0.6, 0.38, 0.18], "ability_modules": [{"type": "minion_call", "cooldown": 5.8, "initial_delay": 1.8, "count": 5, "phase_count_bonus": 2}, {"type": "hazard_ring", "cooldown": 6.8, "initial_delay": 3.2, "count": 9, "phase_count_bonus": 1, "radius": 74.0, "ring_distance": 215.0, "damage": 5}, {"type": "target_hazard", "cooldown": 5.4, "initial_delay": 5.5, "radius": 70.0, "damage": 5}]},
	{"id": "prism_regent", "maps": ["map3"], "scene": BOSS_ENEMY, "unlock_seconds": 0.0, "weight": 112.0, "growth_per_minute": -1.2, "min_weight": 58.0, "max_weight": 112.0, "health": 2450, "speed": 34.0, "contact_damage": 11, "exp_drop_count": 62, "exp_drop_min_tier": 3, "color": Color(0.4, 0.9, 1.0, 1.0), "scale": 1.06, "behavior": "tempest", "texture": "res://assets/visual/enemies/map3/boss_prism_regent.png", "phase_thresholds": [0.7, 0.42, 0.2], "ability_modules": [{"type": "target_hazard", "cooldown": 4.8, "initial_delay": 1.8, "radius": 54.0, "damage": 4}, {"type": "hazard_ring", "cooldown": 6.2, "initial_delay": 3.8, "count": 7, "phase_count_bonus": 1, "radius": 52.0, "ring_distance": 180.0, "damage": 4}]},
	{"id": "crystal_hydra", "maps": ["map3"], "scene": BOSS_ENEMY, "unlock_seconds": 540.0, "weight": 84.0, "growth_per_minute": 1.9, "min_weight": 0.0, "max_weight": 112.0, "health": 3500, "speed": 25.0, "contact_damage": 14, "exp_drop_count": 86, "exp_drop_min_tier": 4, "color": Color(0.78, 0.44, 1.0, 1.0), "scale": 1.28, "behavior": "monarch", "texture": "res://assets/visual/enemies/map3/boss_crystal_hydra.png", "phase_thresholds": [0.78, 0.56, 0.34, 0.16], "ability_modules": [{"type": "minion_call", "cooldown": 6.0, "initial_delay": 2.2, "count": 4, "phase_count_bonus": 2}, {"type": "target_hazard", "cooldown": 5.0, "initial_delay": 4.0, "radius": 60.0, "damage": 5}]},
	{"id": "toxlord", "maps": ["map4"], "scene": BOSS_ENEMY, "unlock_seconds": 0.0, "weight": 118.0, "growth_per_minute": -0.8, "min_weight": 68.0, "max_weight": 118.0, "health": 4200, "speed": 21.0, "contact_damage": 16, "exp_drop_count": 78, "exp_drop_min_tier": 4, "color": Color(0.65, 1.0, 0.12, 1.0), "scale": 1.34, "behavior": "bastion", "texture": "res://assets/visual/enemies/map4/boss_toxlord.png", "phase_thresholds": [0.75, 0.5, 0.25], "ability_modules": [{"type": "hazard_ring", "cooldown": 5.8, "initial_delay": 2.0, "count": 8, "phase_count_bonus": 2, "radius": 66.0, "ring_distance": 175.0, "damage": 5}, {"type": "minion_call", "cooldown": 7.0, "initial_delay": 4.0, "count": 4, "phase_count_bonus": 2}]},
	{"id": "furnace_queen", "maps": ["map4"], "scene": BOSS_ENEMY, "unlock_seconds": 600.0, "weight": 88.0, "growth_per_minute": 2.0, "min_weight": 0.0, "max_weight": 118.0, "health": 5200, "speed": 18.0, "contact_damage": 20, "exp_drop_count": 104, "exp_drop_min_tier": 4, "color": Color(0.95, 0.8, 0.16, 1.0), "scale": 1.5, "behavior": "overlord", "texture": "res://assets/visual/enemies/map4/boss_furnace_queen.png", "phase_thresholds": [0.82, 0.62, 0.42, 0.2], "ability_modules": [{"type": "hazard_ring", "cooldown": 5.6, "initial_delay": 1.7, "count": 9, "phase_count_bonus": 2, "radius": 76.0, "ring_distance": 210.0, "damage": 6}, {"type": "target_hazard", "cooldown": 4.8, "initial_delay": 3.3, "radius": 68.0, "damage": 6}, {"type": "minion_call", "cooldown": 7.2, "initial_delay": 5.0, "count": 5, "phase_count_bonus": 2}]},
	{"id": "rift_seraph", "maps": ["map5"], "scene": BOSS_ENEMY, "unlock_seconds": 0.0, "weight": 120.0, "growth_per_minute": -0.4, "min_weight": 72.0, "max_weight": 120.0, "health": 5600, "speed": 36.0, "contact_damage": 18, "exp_drop_count": 90, "exp_drop_min_tier": 4, "color": Color(0.72, 0.3, 1.0, 1.0), "scale": 1.16, "behavior": "wraith", "texture": "res://assets/visual/enemies/map5/boss_rift_seraph.png", "phase_thresholds": [0.72, 0.48, 0.24], "ability_modules": [{"type": "target_hazard", "cooldown": 3.8, "initial_delay": 1.3, "radius": 62.0, "damage": 6}, {"type": "minion_call", "cooldown": 6.2, "initial_delay": 3.8, "count": 5, "phase_count_bonus": 2}]},
	{"id": "void_emperor", "maps": ["map5"], "scene": BOSS_ENEMY, "unlock_seconds": 480.0, "weight": 96.0, "growth_per_minute": 2.4, "min_weight": 0.0, "max_weight": 128.0, "health": 7200, "speed": 28.0, "contact_damage": 24, "exp_drop_count": 128, "exp_drop_min_tier": 4, "color": Color(0.34, 0.08, 0.66, 1.0), "scale": 1.58, "behavior": "singularity", "texture": "res://assets/visual/enemies/map5/boss_void_emperor.png", "phase_thresholds": [0.84, 0.66, 0.48, 0.3, 0.14], "ability_modules": [{"type": "hazard_ring", "cooldown": 4.8, "initial_delay": 1.5, "count": 10, "phase_count_bonus": 2, "radius": 72.0, "ring_distance": 195.0, "damage": 7}, {"type": "target_hazard", "cooldown": 3.9, "initial_delay": 3.0, "radius": 74.0, "damage": 7}, {"type": "minion_call", "cooldown": 5.8, "initial_delay": 4.8, "count": 6, "phase_count_bonus": 2}]},
]

var enemy_affix_catalog: Array[Dictionary] = [
	{"id": "hasty", "name": "Hasty", "unlock_seconds": 90.0, "weight": 28.0, "speed_multiplier": 1.45, "health_multiplier": 0.85, "color": Color(1.0, 0.95, 0.16, 1.0)},
	{"id": "armored", "name": "Armored", "unlock_seconds": 150.0, "weight": 24.0, "speed_multiplier": 0.82, "health_multiplier": 1.85, "scale_multiplier": 1.12, "color": Color(0.62, 0.72, 0.84, 1.0)},
	{"id": "rich", "name": "Rich", "unlock_seconds": 210.0, "weight": 18.0, "health_multiplier": 1.2, "exp_drop_multiplier": 2.4, "exp_drop_min_tier_bonus": 1, "color": Color(0.46, 1.0, 0.35, 1.0)},
	{"id": "volatile", "name": "Volatile", "unlock_seconds": 300.0, "weight": 16.0, "speed_multiplier": 1.18, "health_multiplier": 0.9, "death_effect": "volatile", "death_radius": 92.0, "death_damage": 34.0, "color": Color(1.0, 0.18, 0.08, 1.0)},
	{"id": "splitting", "name": "Splitting", "unlock_seconds": 420.0, "weight": 14.0, "health_multiplier": 1.35, "death_effect": "split", "split_count": 2, "split_health": 8, "split_speed": 82.0, "color": Color(0.95, 0.36, 1.0, 1.0)},
]

var run_event_catalog: Array[Dictionary] = [
	{"id": "crystal_bloom", "name": "Crystal Bloom", "summary": "Richer EXP while enemy damage spikes.", "duration": 48.0, "weight": 28.0, "effects": {"exp_value_multiplier": 1.35, "enemy_damage_multiplier": 1.12}},
	{"id": "supply_cache", "name": "Supply Cache", "summary": "A cache drops offscreen.", "duration": 0.0, "weight": 24.0, "rewards": {"green_supply": 2, "blue_supply": 1}},
	{"id": "elite_bounty", "name": "Elite Bounty", "summary": "An elite wave arrives with an upgrade reward.", "duration": 0.0, "weight": 22.0, "risks": {"elite_wave_count": 5}, "rewards": {"upgrade_choices": 1}},
	{"id": "overrun_gambit", "name": "Overrun Gambit", "summary": "Enemy pressure surges, then grants an ability choice.", "duration": 36.0, "weight": 20.0, "effects": {"spawn_interval_multiplier": 0.72, "enemy_speed_multiplier": 1.1}, "rewards": {"ability_choices": 1}},
]


func add_autonomous_enemy_content() -> void:
	for entry in LateMapEnemyCatalog.get_entries(ENEMY, BROWN_ENEMY, SHIELDED_ENEMY):
		add_enemy_variant(entry)


func add_enemy_variant(config: Dictionary) -> void:
	for enemy_config in enemy_variant_catalog:
		if String(enemy_config.id) == String(config.id):
			return
	enemy_variant_catalog.append(config)


func add_autonomous_boss_content() -> void:
	add_boss_variant({"id": "grave_bell", "maps": ["map6"], "scene": BOSS_ENEMY, "unlock_seconds": 0.0, "weight": 118.0, "growth_per_minute": -0.6, "min_weight": 70.0, "max_weight": 118.0, "health": 6200, "speed": 24.0, "contact_damage": 18, "exp_drop_count": 92, "exp_drop_min_tier": 4, "color": Color(0.46, 0.52, 0.88, 1.0), "scale": 1.28, "behavior": "wraith", "texture": "res://assets/visual/enemies/variants/enemy_orbiter_cartoon.png", "phase_thresholds": [0.74, 0.48, 0.22], "ability_modules": [{"type": "target_hazard", "cooldown": 3.8, "initial_delay": 1.4, "radius": 64.0, "damage": 6}, {"type": "minion_call", "cooldown": 6.0, "initial_delay": 3.5, "count": 4, "phase_count_bonus": 2}]})
	add_boss_variant({"id": "crypt_marshal", "maps": ["map6"], "scene": BOSS_ENEMY, "unlock_seconds": 480.0, "weight": 92.0, "growth_per_minute": 2.2, "min_weight": 0.0, "max_weight": 128.0, "health": 8200, "speed": 18.0, "contact_damage": 22, "exp_drop_count": 122, "exp_drop_min_tier": 4, "color": Color(0.28, 0.3, 0.56, 1.0), "scale": 1.55, "behavior": "bastion", "texture": "res://assets/visual/enemies/variants/enemy_tank_cartoon.png", "phase_thresholds": [0.82, 0.64, 0.42, 0.2], "ability_modules": [{"type": "hazard_ring", "cooldown": 5.2, "initial_delay": 2.0, "count": 9, "phase_count_bonus": 2, "radius": 72.0, "ring_distance": 190.0, "damage": 6}, {"type": "minion_call", "cooldown": 7.2, "initial_delay": 4.8, "count": 5, "phase_count_bonus": 2}]})
	add_boss_variant({"id": "neon_executioner", "maps": ["map7"], "scene": BOSS_ENEMY, "unlock_seconds": 0.0, "weight": 120.0, "growth_per_minute": -0.8, "min_weight": 72.0, "max_weight": 120.0, "health": 6500, "speed": 42.0, "contact_damage": 19, "exp_drop_count": 98, "exp_drop_min_tier": 4, "color": Color(0.06, 0.92, 1.0, 1.0), "scale": 1.02, "behavior": "tempest", "texture": "res://assets/visual/enemies/variants/enemy_zigzag_cartoon.png", "phase_thresholds": [0.7, 0.42, 0.18], "ability_modules": [{"type": "target_hazard", "cooldown": 3.2, "initial_delay": 1.1, "radius": 54.0, "damage": 6}, {"type": "hazard_ring", "cooldown": 5.0, "initial_delay": 3.0, "count": 7, "phase_count_bonus": 1, "radius": 50.0, "ring_distance": 170.0, "damage": 5}]})
	add_boss_variant({"id": "grid_overseer", "maps": ["map7"], "scene": BOSS_ENEMY, "unlock_seconds": 540.0, "weight": 90.0, "growth_per_minute": 2.5, "min_weight": 0.0, "max_weight": 132.0, "health": 9000, "speed": 28.0, "contact_damage": 23, "exp_drop_count": 130, "exp_drop_min_tier": 4, "color": Color(0.95, 0.25, 1.0, 1.0), "scale": 1.34, "behavior": "overlord", "texture": "res://assets/visual/enemies/variants/enemy_reaper_cartoon.png", "phase_thresholds": [0.78, 0.56, 0.34, 0.14], "ability_modules": [{"type": "hazard_ring", "cooldown": 4.6, "initial_delay": 1.6, "count": 10, "phase_count_bonus": 1, "radius": 62.0, "ring_distance": 205.0, "damage": 6}, {"type": "target_hazard", "cooldown": 4.0, "initial_delay": 4.0, "radius": 66.0, "damage": 7}]})
	add_boss_variant({"id": "frost_leviathan", "maps": ["map8"], "scene": BOSS_ENEMY, "unlock_seconds": 0.0, "weight": 118.0, "growth_per_minute": -0.4, "min_weight": 74.0, "max_weight": 118.0, "health": 9800, "speed": 18.0, "contact_damage": 24, "exp_drop_count": 112, "exp_drop_min_tier": 4, "color": Color(0.64, 0.92, 1.0, 1.0), "scale": 1.62, "behavior": "crusher", "texture": "res://assets/visual/enemies/variants/enemy_tank_cartoon.png", "phase_thresholds": [0.8, 0.58, 0.36, 0.16], "ability_modules": [{"type": "hazard_ring", "cooldown": 5.4, "initial_delay": 2.0, "count": 8, "phase_count_bonus": 2, "radius": 76.0, "ring_distance": 220.0, "damage": 7}]})
	add_boss_variant({"id": "blizzard_matriarch", "maps": ["map8"], "scene": BOSS_ENEMY, "unlock_seconds": 600.0, "weight": 86.0, "growth_per_minute": 2.4, "min_weight": 0.0, "max_weight": 130.0, "health": 8600, "speed": 34.0, "contact_damage": 21, "exp_drop_count": 136, "exp_drop_min_tier": 4, "color": Color(0.38, 0.76, 1.0, 1.0), "scale": 1.22, "behavior": "monarch", "texture": "res://assets/visual/enemies/variants/enemy_drifter_cartoon.png", "phase_thresholds": [0.76, 0.52, 0.28], "ability_modules": [{"type": "minion_call", "cooldown": 5.4, "initial_delay": 2.2, "count": 5, "phase_count_bonus": 2}, {"type": "target_hazard", "cooldown": 4.4, "initial_delay": 4.0, "radius": 68.0, "damage": 6}]})
	add_boss_variant({"id": "magma_tyrant", "maps": ["map9"], "scene": BOSS_ENEMY, "unlock_seconds": 0.0, "weight": 122.0, "growth_per_minute": -0.5, "min_weight": 76.0, "max_weight": 122.0, "health": 10400, "speed": 30.0, "contact_damage": 28, "exp_drop_count": 126, "exp_drop_min_tier": 4, "color": Color(1.0, 0.22, 0.06, 1.0), "scale": 1.46, "behavior": "overlord", "texture": "res://assets/visual/enemies/variants/enemy_reaper_cartoon.png", "phase_thresholds": [0.82, 0.62, 0.42, 0.18], "ability_modules": [{"type": "target_hazard", "cooldown": 3.6, "initial_delay": 1.2, "radius": 74.0, "damage": 8}, {"type": "hazard_ring", "cooldown": 4.8, "initial_delay": 3.0, "count": 9, "phase_count_bonus": 2, "radius": 70.0, "ring_distance": 185.0, "damage": 7}]})
	add_boss_variant({"id": "cinder_prophet", "maps": ["map9"], "scene": BOSS_ENEMY, "unlock_seconds": 520.0, "weight": 92.0, "growth_per_minute": 2.7, "min_weight": 0.0, "max_weight": 136.0, "health": 7800, "speed": 46.0, "contact_damage": 22, "exp_drop_count": 142, "exp_drop_min_tier": 4, "color": Color(1.0, 0.62, 0.12, 1.0), "scale": 1.05, "behavior": "sprinter", "texture": "res://assets/visual/enemies/variants/enemy_runner_cartoon.png", "phase_thresholds": [0.68, 0.38, 0.16], "ability_modules": [{"type": "target_hazard", "cooldown": 3.0, "initial_delay": 1.0, "radius": 56.0, "damage": 7}, {"type": "minion_call", "cooldown": 5.6, "initial_delay": 3.5, "count": 4, "phase_count_bonus": 2}]})
	add_boss_variant({"id": "astral_archon", "maps": ["map10"], "scene": BOSS_ENEMY, "unlock_seconds": 0.0, "weight": 124.0, "growth_per_minute": -0.2, "min_weight": 82.0, "max_weight": 124.0, "health": 11200, "speed": 38.0, "contact_damage": 30, "exp_drop_count": 150, "exp_drop_min_tier": 4, "color": Color(0.68, 0.42, 1.0, 1.0), "scale": 1.34, "behavior": "singularity", "texture": "res://assets/visual/enemies/variants/enemy_zigzag_cartoon.png", "phase_thresholds": [0.86, 0.68, 0.5, 0.32, 0.14], "ability_modules": [{"type": "hazard_ring", "cooldown": 4.2, "initial_delay": 1.3, "count": 11, "phase_count_bonus": 2, "radius": 66.0, "ring_distance": 210.0, "damage": 8}, {"type": "target_hazard", "cooldown": 3.4, "initial_delay": 2.8, "radius": 72.0, "damage": 8}, {"type": "minion_call", "cooldown": 5.2, "initial_delay": 4.6, "count": 6, "phase_count_bonus": 2}]})
	add_boss_variant({"id": "engine_heart", "maps": ["map10"], "scene": BOSS_ENEMY, "unlock_seconds": 660.0, "weight": 96.0, "growth_per_minute": 2.8, "min_weight": 0.0, "max_weight": 144.0, "health": 14800, "speed": 20.0, "contact_damage": 34, "exp_drop_count": 180, "exp_drop_min_tier": 4, "color": Color(0.18, 0.96, 1.0, 1.0), "scale": 1.72, "behavior": "bastion", "texture": "res://assets/visual/enemies/variants/enemy_tank_cartoon.png", "phase_thresholds": [0.88, 0.72, 0.56, 0.4, 0.24, 0.1], "ability_modules": [{"type": "hazard_ring", "cooldown": 4.0, "initial_delay": 1.4, "count": 12, "phase_count_bonus": 2, "radius": 80.0, "ring_distance": 240.0, "damage": 9}, {"type": "minion_call", "cooldown": 4.8, "initial_delay": 3.8, "count": 7, "phase_count_bonus": 2}]})


func add_boss_variant(config: Dictionary) -> void:
	for boss_config in boss_variant_catalog:
		if String(boss_config.id) == String(config.id):
			return
	boss_variant_catalog.append(config)


const MAGNET_DURATION: float = 5.0
const MAGNET_SPAWN_INTERVAL: float = 180.0
const SUPPLY_BOX_SPAWN_INTERVAL: float = 15.0
const SUPPLY_BOX_SPAWN_CHANCE: float = 0.05
const BLUE_SUPPLY_BOX_CHANCE: float = 0.2
const BOSS_SPAWN_INTERVAL: float = 180.0
const ENEMY_HEALTH_SCALE_INTERVAL: float = 30.0
const ENEMY_HEALTH_BONUS_STEP: float = 0.01
const ENEMY_DAMAGE_SCALE_INTERVAL: float = 60.0
const ENEMY_DAMAGE_MULTIPLIER_STEP: float = 1.05
const PLAYER_DPS_WINDOW: float = 10.0
const PLAYER_DPS_AVERAGE_HP_PRIORITY_MULTIPLIER: float = 3.0
const LOW_HEALTH_UPGRADE_RATIO: float = 0.7
const LOW_HEALTH_REGEN_PRIORITY_TIME: float = 30.0
const RED_ENEMY_BASE_HEALTH: float = 14.0
const BROWN_ENEMY_BASE_HEALTH: float = 16.0
const SHIELDED_ENEMY_BASE_HEALTH: float = 40.0
const DYNAMITE_DAMAGE: float = 9999.0
const DYNAMITE_BOSS_DAMAGE: float = 300.0
const DYNAMITE_DROP_CHANCE: float = 0.001
const WRENCH_DROP_CHANCE: float = 0.05
const MAX_ACTIVE_WRENCH_PICKUPS: int = 10
const PURPLE_ORB_START_TIME: float = 300.0
const VIOLET_ORB_START_TIME: float = 600.0
const EXP_DROPS_PER_FRAME: int = 20
const MAX_ACTIVE_EXP_ORBS: int = 100
const PROJECTILE_POOL_LIMIT: int = 220
const PARTICLE_BURST_POOL_LIMIT: int = 48
const MAX_DAMAGE_NUMBERS_PER_FRAME: int = 18
const MAX_PROJECTILE_HIT_FEEDBACK_PER_FRAME: int = 10
const MAX_ACTIVE_PARTICLE_BURSTS: int = 36
const MAX_ACTIVE_SPLASH_AREAS: int = 24
const MAX_ACTIVE_BOSS_HAZARDS: int = 18
const MASS_SPLASH_ENEMY_THRESHOLD: int = 12
const BASE_ACTIVE_ENEMY_CAP: int = 85
const MAX_ACTIVE_ENEMY_CAP: int = 225
const ACTIVE_ENEMY_CAP_GROWTH_PER_MINUTE: float = 8.0
const BOSS_RESERVE_ENEMY_PRESSURE: int = 16
const PRESSURE_MINION_SPAWN_RATIO: float = 0.92
const PRESSURE_SPLIT_SPAWN_RATIO: float = 0.96
const VISIBILITY_CULL_MARGIN: float = 160.0
const VISIBILITY_CULL_GROUPS: Array[String] = [
	"Enemy",
	"ExpOrb",
	"MagnetPickup",
	"DynamitePickup",
	"WrenchPickup",
	"SupplyBoxPickup",
	"Landmine",
	"Projectile",
	"CircularSaw",
	"FootSoldier",
]
const BLUE_ORB_TIER: int = 1
const ORANGE_ORB_TIER: int = 2
const PURPLE_ORB_TIER: int = 3
const VIOLET_ORB_TIER: int = 4
const BOSS_ARENA_INSET: float = 80.0
const ELITE_CHANCE_START_SECONDS: float = 90.0
const ELITE_CHANCE_FULL_SECONDS: float = 900.0
const ELITE_CHANCE_MAX: float = 0.18
const ELITE_SPLIT_ACTIVE_ENEMY_CAP: int = 180
const MOVEMENT_INPUT_ACTIONS: Array[String] = [
	"move_left",
	"move_right",
	"move_up",
	"move_down",
]
const DEBUG_TIME_SCALES: Array[float] = [1.0, 2.0, 4.0, 8.0]
const VICTORY_TIME_SECONDS: float = 1800.0
const DROP_CLEARANCE: float = 18.0
const ENEMY_OBSTACLE_CLEARANCE: float = 18.0

@onready var arena_mesh: MeshInstance2D = $ArenaMesh
@onready var bounds_mesh: MeshInstance2D = $BoundsMesh
@onready var wasteland_background: Sprite2D = $WastelandBackground
@onready var world_mood: CanvasModulate = $WorldMood
@onready var boundary_body: StaticBody2D = $StaticBody2D
@onready var map_layout: Node2D = $MapLayout
@onready var hp_bar: Control = $CanvasLayer/HPBar
@onready var exp_bar: Control = $CanvasLayer/ExpBar
@onready var run_timer_label: Label = $CanvasLayer/RunTimerLabel
@onready var stats_label: Label = $CanvasLayer/StatsLabel
@onready var upgrade_inventory_label: Label = $CanvasLayer/UpgradeInventoryLabel
@onready var damage_number_pool: Node2D = $DamageNumberPool
@onready var low_health_vignette: Control = $CanvasLayer/LowHealthVignette
@onready var dynamite_flash: ColorRect = $CanvasLayer/DynamiteFlash
@onready var loading_overlay: Control = $CanvasLayer/LoadingOverlay
@onready var pause_button: Button = $CanvasLayer/PauseButton
@onready var pause_overlay: Control = $CanvasLayer/PauseOverlay
@onready var debug_all_ai_button: Button = $CanvasLayer/DebugAllAiButton
@onready var debug_auto_move_button: Button = $CanvasLayer/DebugAutoMoveButton
@onready var debug_enemy_avoidance_button: Button = $CanvasLayer/DebugEnemyAvoidanceButton
@onready var debug_exp_seek_button: Button = $CanvasLayer/DebugExpSeekButton
@onready var debug_wrench_seek_button: Button = $CanvasLayer/DebugWrenchSeekButton
@onready var debug_powerup_seek_button: Button = $CanvasLayer/DebugPowerupSeekButton
@onready var debug_supply_seek_button: Button = $CanvasLayer/DebugSupplySeekButton
@onready var debug_upgrade_pick_button: Button = $CanvasLayer/DebugUpgradePickButton
@onready var debug_time_scale_button: Button = $CanvasLayer/DebugTimeScaleButton


func _ready() -> void:
	GamepadInputSetup.ensure_configured()
	add_autonomous_enemy_content()
	add_autonomous_boss_content()
	setup_pause_input_router()
	configure_run_seed_and_modifiers()
	configure_selected_map()
	set_debug_time_scale_index(0)
	hide_player_facing_debug_ui()
	is_startup_loading = true
	loading_overlay.visible = true
	loading_overlay.modulate.a = 1.0
	get_tree().paused = true
	%DefeatControl.visible = false
	pause_overlay.visible = false
	player = get_node("Player")
	setup_pickup_pools()
	player.upgrade_recieved.connect(func(): spawn_interval = max(spawn_interval - 0.05, 0.2))
	player.exp_changed.connect(_on_player_exp_changed)
	player.health_changed.connect(_on_player_health_changed)
	player.damaged.connect(_on_player_damaged)
	_on_player_exp_changed(player.current_exp, player.get_required_exp(), player.level)
	_on_player_health_changed(player.health, player.max_health)
	update_stats_label()
	update_upgrade_inventory_label()
	call_deferred("run_startup_loading")
	player.defeated.connect(func(): complete_run(false))


func hide_player_facing_debug_ui() -> void:
	stats_label.visible = false
	upgrade_inventory_label.visible = false
	for child in $CanvasLayer.get_children():
		if child.name.begins_with("Debug"):
			child.visible = false


func complete_run(victory: bool) -> void:
	if run_completed:
		return
	run_completed = true
	run_was_victory = victory
	set_all_ai_toggles_active(false)
	low_health_vignette.set_low_health_active(false)
	get_tree().paused = true
	%DefeatControl.visible = true
	%DefeatControl.get_node("RestartButton").grab_focus.call_deferred()
	var result := {
		"victory": victory,
		"survival_seconds": int(floor(max(run_time, VICTORY_TIME_SECONDS if victory else run_time))),
		"level": player.level,
		"enemies_defeated": enemies_defeated,
		"bosses_defeated": bosses_defeated,
		"elites_defeated": elites_defeated,
		"map_id": selected_map_id,
		"build_levels": get_build_level_snapshot(),
	}
	var unlocked_messages: Array[String] = get_unlock_manager().record_run_result(result)
	%DefeatControl.get_node("DefeatLabel").text = "VICTORY" if victory else "RUN OVER"
	%DefeatControl.get_node("DefeatLabel").add_theme_color_override("font_color", Color(0.38, 1.0, 0.42, 1.0) if victory else Color(1.0, 0.0, 0.0, 1.0))
	%ResultLabel.text = get_run_summary_text(unlocked_messages)


func configure_run_seed_and_modifiers() -> void:
	var run_config = get_run_config()
	run_config.ensure_run_ready()
	run_seed_text = String(run_config.run_seed_text)
	run_modifier_summary = String(run_config.get_active_modifier_summary())
	seed(hash(run_seed_text))
	
	enemy_speed_growth_multiplier = float(run_config.get_modifier_multiplier("enemy_speed_growth_multiplier"))
	enemy_health_growth_multiplier = float(run_config.get_modifier_multiplier("enemy_health_growth_multiplier"))
	enemy_damage_growth_multiplier = float(run_config.get_modifier_multiplier("enemy_damage_growth_multiplier"))
	exp_value_multiplier = float(run_config.get_modifier_multiplier("exp_value_multiplier"))
	boss_exp_multiplier = float(run_config.get_modifier_multiplier("boss_exp_multiplier"))
	boss_spawn_interval = BOSS_SPAWN_INTERVAL * float(run_config.get_modifier_multiplier("boss_spawn_interval_multiplier"))
	supply_box_spawn_interval = SUPPLY_BOX_SPAWN_INTERVAL * float(run_config.get_modifier_multiplier("supply_box_interval_multiplier"))
	supply_box_spawn_chance = clamp(SUPPLY_BOX_SPAWN_CHANCE * float(run_config.get_modifier_multiplier("supply_box_chance_multiplier")), 0.0, 1.0)
	wrench_drop_chance = clamp(WRENCH_DROP_CHANCE * float(run_config.get_modifier_multiplier("wrench_drop_multiplier")) * float(run_config.get_meta_reward_multiplier("wrench_drop_multiplier")), 0.0, 1.0)
	dynamite_drop_chance = clamp(DYNAMITE_DROP_CHANCE * float(run_config.get_modifier_multiplier("dynamite_drop_multiplier")) * float(run_config.get_meta_reward_multiplier("dynamite_drop_multiplier")), 0.0, 1.0)
	spawn_interval *= float(run_config.get_modifier_multiplier("spawn_interval_multiplier"))
	build_run_event_schedule()


func configure_selected_map() -> void:
	var map_config: Dictionary = get_run_config().get_selected_map()
	selected_map_id = String(map_config.get("id", "map1"))
	selected_map_name = String(map_config.get("name", "Dust Bowl"))
	spawn_interval *= float(map_config.get("spawn_interval_multiplier", 1.0))
	boss_spawn_interval *= float(map_config.get("boss_spawn_interval_multiplier", 1.0))
	enemy_speed_growth_multiplier *= float(map_config.get("enemy_speed_growth_multiplier", 1.0))
	enemy_health_growth_multiplier *= float(map_config.get("enemy_health_growth_multiplier", 1.0))
	enemy_damage_growth_multiplier *= float(map_config.get("enemy_damage_growth_multiplier", 1.0))
	active_enemy_cap_bonus = int(map_config.get("active_enemy_cap_bonus", 0))
	active_enemy_cap_limit = int(map_config.get("active_enemy_cap_limit", MAX_ACTIVE_ENEMY_CAP))
	elite_chance_multiplier = float(map_config.get("elite_chance_multiplier", 1.0))
	map_gimmick = String(map_config.get("map_gimmick", ""))
	map_gimmick_interval = float(map_config.get("gimmick_interval", 0.0))
	map_gimmick_timer = map_gimmick_interval * 0.5
	var background_texture_path := String(map_config.get("background_texture", ""))
	if background_texture_path != "" and ResourceLoader.exists(background_texture_path):
		wasteland_background.texture = load(background_texture_path)
	if world_mood:
		world_mood.color = map_config.get("mood_color", Color(0.9, 0.93, 1.0, 1.0)) as Color
	if map_layout and map_layout.has_method("apply_map"):
		map_layout.apply_map(selected_map_id)
		apply_map_scene_dimensions()


func apply_map_scene_dimensions() -> void:
	if map_layout == null:
		return
	var arena_size: Vector2 = map_layout.get_arena_size()
	var bounds_size: Vector2 = map_layout.get_bounds_size()
	if arena_mesh.mesh is QuadMesh:
		(arena_mesh.mesh as QuadMesh).size = arena_size
	if bounds_mesh.mesh is QuadMesh:
		(bounds_mesh.mesh as QuadMesh).size = bounds_size
	if wasteland_background.texture:
		var texture_size: Vector2 = wasteland_background.texture.get_size()
		var cover_scale: float = max(bounds_size.x / texture_size.x, bounds_size.y / texture_size.y)
		wasteland_background.scale = Vector2.ONE * cover_scale
	var vertical_wall_size := Vector2(64.0, bounds_size.y - 192.0)
	var horizontal_wall_size := Vector2(bounds_size.x - 192.0, 64.0)
	for collision_shape in boundary_body.get_children():
		if not collision_shape is CollisionShape2D:
			continue
		var shape := (collision_shape as CollisionShape2D).shape
		if not shape is RectangleShape2D:
			continue
		if abs((collision_shape as CollisionShape2D).position.x) > abs((collision_shape as CollisionShape2D).position.y):
			(shape as RectangleShape2D).size = vertical_wall_size
			(collision_shape as CollisionShape2D).position.x = sign((collision_shape as CollisionShape2D).position.x) * ((arena_size.x + 64.0) / 2.0)
		else:
			(shape as RectangleShape2D).size = horizontal_wall_size
			(collision_shape as CollisionShape2D).position.y = sign((collision_shape as CollisionShape2D).position.y) * ((arena_size.y + 64.0) / 2.0)


func get_run_config() -> Node:
	return get_node("/root/RunConfig")


func get_unlock_manager() -> Node:
	return get_node("/root/UnlockManager")


func setup_pause_input_router() -> void:
	pause_input_router = PauseInputRouter.new()
	pause_input_router.name = "PauseInputRouter"
	pause_input_router.pause_requested.connect(_on_pause_input_requested)
	pause_input_router.restart_requested.connect(_on_restart_input_requested)
	add_child(pause_input_router)


func setup_pickup_pools() -> void:
	magnet_pickup_pool = MAGNET_PICKUP.instantiate()
	add_child(magnet_pickup_pool)
	magnet_pickup_pool.deactivate()
	
	dynamite_pickup_pool = DYNAMITE_PICKUP.instantiate()
	add_child(dynamite_pickup_pool)
	dynamite_pickup_pool.deactivate()
	
	for i in range(MAX_ACTIVE_WRENCH_PICKUPS):
		var wrench_pickup = WRENCH_PICKUP.instantiate()
		add_child(wrench_pickup)
		wrench_pickup.deactivate()
		wrench_pickup_pool.append(wrench_pickup)


func _process(delta: float) -> void:
	if is_startup_loading:
		return
	if get_tree().paused:
		return
	
	damage_numbers_this_frame = 0
	projectile_hit_feedback_this_frame = 0
	cancel_ai_on_manual_movement_input()
	low_health_vignette.set_low_health_active(player.health > 0 and player.get_health_ratio() <= 0.4)
	dynamite_flash.color.a = move_toward(dynamite_flash.color.a, 0.0, 7.0 * delta)
	update_stats_label()
	process_queued_exp_drops()
	update_visibility_culling()
	run_time += delta
	if run_time >= VICTORY_TIME_SECONDS:
		complete_run(true)
		return
	update_player_dps()
	update_low_health_upgrade_timer(delta)
	process_run_events(delta)
	process_map_gimmick(delta)
	update_run_timer_label()
	update_upgrade_inventory_label()
	spawn_timer += delta
	enemy_speed_scale_timer += delta
	enemy_health_scale_timer += delta
	enemy_damage_scale_timer += delta
	boss_spawn_timer += delta
	magnet_spawn_timer += delta
	supply_box_spawn_timer += delta
	
	if magnet_effect_timer > 0.0:
		magnet_effect_timer = max(magnet_effect_timer - delta, 0.0)
		if magnet_effect_timer <= 0.0:
			set_exp_orbs_magnet_active(false)
	
	while enemy_speed_scale_timer >= 10.0:
		enemy_speed_scale_timer -= 10.0
		enemy_speed_scale *= 1.0 + 0.01 * enemy_speed_growth_multiplier
		update_exp_orb_drop_chances()
		
		for enemy in active_enemies:
			if enemy.has_method("apply_speed_multiplier"):
				enemy.apply_speed_multiplier(1.0 + 0.01 * enemy_speed_growth_multiplier)
	
	while enemy_health_scale_timer >= ENEMY_HEALTH_SCALE_INTERVAL:
		enemy_health_scale_timer -= ENEMY_HEALTH_SCALE_INTERVAL
		enemy_health_bonus_step += ENEMY_HEALTH_BONUS_STEP * enemy_health_growth_multiplier
		enemy_health_bonus_total += enemy_health_bonus_step
		apply_enemy_health_bonus_to_active_enemies()
	
	while enemy_damage_scale_timer >= ENEMY_DAMAGE_SCALE_INTERVAL:
		enemy_damage_scale_timer -= ENEMY_DAMAGE_SCALE_INTERVAL
		enemy_damage_multiplier *= 1.0 + ((ENEMY_DAMAGE_MULTIPLIER_STEP - 1.0) * enemy_damage_growth_multiplier)
	
	if magnet_spawn_timer >= MAGNET_SPAWN_INTERVAL:
		magnet_spawn_timer -= MAGNET_SPAWN_INTERVAL
		try_spawn_magnet_pickup()
	
	if supply_box_spawn_timer >= supply_box_spawn_interval:
		supply_box_spawn_timer -= supply_box_spawn_interval
		try_spawn_supply_box()
	
	if boss_spawn_timer >= boss_spawn_interval:
		boss_spawn_timer -= boss_spawn_interval
		try_spawn_boss()
	
	if spawn_timer >= get_effective_spawn_interval():
		if can_spawn_regular_enemy():
			var enemy_config := get_enemy_config_to_spawn()
			enemy_config = apply_random_elite_affix(enemy_config)
			spawn_enemy(enemy_config.scene, _on_enemy_defeated, enemy_config)
		else:
			spawn_skips_from_pressure += 1
		spawn_timer = 0.0


func run_startup_loading() -> void:
	await get_tree().process_frame
	await warmup_runtime_scenes()
	await fade_loading_overlay()
	loading_overlay.visible = false
	is_startup_loading = false
	if not is_player_paused and not %DefeatControl.visible and not player.upgrade_selection_active and not player.ability_selection_active:
		get_tree().paused = false


func warmup_runtime_scenes() -> void:
	var warmup_root := Node2D.new()
	warmup_root.name = "StartupWarmupRoot"
	warmup_root.visible = false
	warmup_root.position = Vector2(-100000.0, -100000.0)
	add_child(warmup_root)
	
	var warmup_scenes: Array[PackedScene] = [
		ENEMY,
		BROWN_ENEMY,
		SHIELDED_ENEMY,
		BOSS_ENEMY,
		EXP_ORB,
		MAGNET_PICKUP,
		DYNAMITE_PICKUP,
		WRENCH_PICKUP,
		SUPPLY_BOX_BLUE,
		SUPPLY_BOX_GREEN,
		PARTICLE_BURST,
		SPLASH_AREA,
		BOSS_HAZARD,
		HEALING_POPUP,
		PROJECTILE,
		LANDMINE,
		CIRCULAR_SAW,
		FOOTSOLDIER,
		SHOCK_FIELD,
		ARTILLERY_BEACON,
		DRONE_SWARM,
		OIL_SLICK_DISPENSER,
		FREEZE_PULSE,
		UPGRADE_MENU,
		ABILITY_MENU,
	]
	
	for scene in warmup_scenes:
		warmup_scene(warmup_root, scene)
		await get_tree().process_frame
	
	warmup_root.queue_free()
	await get_tree().process_frame


func warmup_scene(warmup_root: Node, scene: PackedScene) -> void:
	var instance := scene.instantiate()
	if instance is CanvasItem:
		instance.visible = false
	if "player" in instance:
		instance.player = player
	if instance.has_method("configure") and instance.scene_file_path.ends_with("footsoldier.tscn"):
		instance.configure(player, 0, 1)
	if instance.has_method("configure") and instance.scene_file_path.ends_with("shock_field.tscn"):
		instance.configure(player, 1)
	if instance.has_method("configure") and instance.scene_file_path.ends_with("artillery_beacon.tscn"):
		instance.configure(player, 1)
	if instance.has_method("configure") and instance.scene_file_path.ends_with("drone_swarm.tscn"):
		instance.configure(player, 1)
	if instance.has_method("configure") and instance.scene_file_path.ends_with("oil_slick_dispenser.tscn"):
		instance.configure(player, 1)
	if instance.has_method("configure") and instance.scene_file_path.ends_with("freeze_pulse.tscn"):
		instance.configure(player, 1)
	warmup_root.add_child(instance)
	
	if instance.has_method("configure") and instance.scene_file_path.ends_with("exp_orb.tscn"):
		instance.configure(1, 5.0, GREEN_EXP_CRYSTAL)
	if instance.has_method("configure") and instance.scene_file_path.ends_with("healing_popup.tscn"):
		instance.configure(Vector2.ZERO, 1)
	if instance.has_method("configure") and instance.scene_file_path.ends_with("splash_area.tscn"):
		var empty_enemies: Array[Area2D] = []
		instance.configure(10.0, 1.0, empty_enemies, false)


func fade_loading_overlay() -> void:
	const FADE_STEPS: int = 15
	for i in range(FADE_STEPS):
		loading_overlay.modulate.a = 1.0 - float(i + 1) / float(FADE_STEPS)
		await get_tree().process_frame


func build_run_event_schedule() -> void:
	run_event_schedule.clear()
	active_run_events.clear()
	completed_run_event_names.clear()
	next_run_event_index = 0
	
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("%s:run_events" % run_seed_text)
	var available_events: Array[Dictionary] = run_event_catalog.duplicate(true)
	var trigger_time := 150.0 + rng.randf_range(-18.0, 18.0)
	for i in range(mini(4, available_events.size())):
		var picked_index := pick_weighted_event_index(available_events, rng)
		var event_config: Dictionary = available_events[picked_index]
		available_events.remove_at(picked_index)
		run_event_schedule.append({
			"trigger_time": trigger_time,
			"config": event_config,
		})
		trigger_time += rng.randf_range(135.0, 175.0)


func pick_weighted_event_index(events: Array[Dictionary], rng: RandomNumberGenerator) -> int:
	var total_weight: float = 0.0
	for event in events:
		total_weight += float(event.get("weight", 1.0))
	
	var roll: float = rng.randf() * max(total_weight, 0.001)
	for i in range(events.size()):
		roll -= float(events[i].get("weight", 1.0))
		if roll <= 0.0:
			return i
	return max(events.size() - 1, 0)


func process_run_events(delta: float) -> void:
	update_active_run_events(delta)
	while next_run_event_index < run_event_schedule.size():
		var scheduled_event: Dictionary = run_event_schedule[next_run_event_index]
		if run_time < float(scheduled_event.trigger_time):
			break
		next_run_event_index += 1
		start_run_event(scheduled_event.config as Dictionary)


func update_active_run_events(delta: float) -> void:
	for i in range(active_run_events.size() - 1, -1, -1):
		var event: Dictionary = active_run_events[i]
		event["remaining"] = float(event.get("remaining", 0.0)) - delta
		active_run_events[i] = event
		if float(event.remaining) <= 0.0:
			active_run_events.remove_at(i)


func start_run_event(event_config: Dictionary) -> void:
	completed_run_event_names.append(String(event_config.name))
	if completed_run_event_names.size() > 6:
		completed_run_event_names.pop_front()
	
	var duration := float(event_config.get("duration", 0.0))
	if duration > 0.0:
		active_run_events.append({
			"config": event_config,
			"remaining": duration,
		})
	
	apply_run_event_risks(event_config)
	apply_run_event_rewards(event_config)
	spawn_run_event_burst()


func apply_run_event_risks(event_config: Dictionary) -> void:
	var risks: Dictionary = event_config.get("risks", {}) as Dictionary
	if risks.has("elite_wave_count"):
		spawn_event_elite_wave(int(risks.elite_wave_count))


func apply_run_event_rewards(event_config: Dictionary) -> void:
	var rewards: Dictionary = event_config.get("rewards", {}) as Dictionary
	for i in range(int(rewards.get("green_supply", 0))):
		spawn_supply_box_at_position(SUPPLY_BOX_GREEN, get_offscreen_arena_spawn_point())
	for i in range(int(rewards.get("blue_supply", 0))):
		spawn_supply_box_at_position(SUPPLY_BOX_BLUE, get_offscreen_arena_spawn_point())
	for i in range(int(rewards.get("upgrade_choices", 0))):
		player.request_supply_upgrade_selection()
	for i in range(int(rewards.get("ability_choices", 0))):
		player.request_supply_ability_selection()


func spawn_event_elite_wave(wave_count: int) -> void:
	for i in range(wave_count):
		if not has_enemy_pressure_room(0):
			spawn_skips_from_pressure += 1
			return
		var enemy_config := get_enemy_config_to_spawn()
		enemy_config = apply_guaranteed_elite_affix(enemy_config)
		var enemy = spawn_enemy(enemy_config.scene, _on_enemy_defeated, enemy_config)
		if enemy is Node2D:
			enemy.global_position = get_spawn_point()


func apply_guaranteed_elite_affix(enemy_config: Dictionary) -> Dictionary:
	var affix := get_affix_config_to_apply()
	if affix.is_empty():
		return enemy_config
	return apply_affix_to_enemy_config(enemy_config, affix)


func get_effective_spawn_interval() -> float:
	return max(spawn_interval * get_active_run_event_multiplier("spawn_interval_multiplier"), 0.15)


func get_active_run_event_multiplier(effect_key: String, default_value: float = 1.0) -> float:
	var multiplier := default_value
	for event in active_run_events:
		var config: Dictionary = event.config as Dictionary
		var effects: Dictionary = config.get("effects", {}) as Dictionary
		multiplier *= float(effects.get(effect_key, 1.0))
	return multiplier


func get_run_event_status_text() -> String:
	if not active_run_events.is_empty():
		var active_names: Array[String] = []
		for event in active_run_events:
			var config: Dictionary = event.config as Dictionary
			active_names.append("%s %.0fs" % [String(config.name), float(event.remaining)])
		return ", ".join(active_names)
	if next_run_event_index < run_event_schedule.size():
		var next_event: Dictionary = run_event_schedule[next_run_event_index]
		return "Next: %s" % get_formatted_seconds(max(float(next_event.trigger_time) - run_time, 0.0))
	if completed_run_event_names.is_empty():
		return "None"
	return "Recent: %s" % completed_run_event_names.back()


func get_run_event_summary_text() -> String:
	if completed_run_event_names.is_empty():
		return "None"
	return ", ".join(completed_run_event_names)


func spawn_run_event_burst() -> void:
	if player == null:
		return
	spawn_particle_burst(self, player.global_position, 48, Color(0.35, 0.9, 1.0, 1.0), 280.0, 0.35, Vector2(4.0, 8.0), true)


func spawn_enemy(enemy_scene: PackedScene, defeated_callback: Callable, variant_config: Dictionary = {}) -> Node:
	var enemy = enemy_scene.instantiate()
	if not variant_config.is_empty() and enemy.has_method("configure_variant"):
		enemy.configure_variant(variant_config)
	enemy.defeated.connect(defeated_callback)
	add_child(enemy)
	register_active_enemy(enemy)
	var spawn_position := get_boss_spawn_point() if enemy.is_in_group("Boss") else get_spawn_point()
	enemy.global_position = get_walkable_drop_position(spawn_position, ENEMY_OBSTACLE_CLEARANCE)
	if enemy.has_method("set_global_speed_scale"):
		enemy.set_global_speed_scale(enemy_speed_scale * get_active_run_event_multiplier("enemy_speed_multiplier"))
	if enemy.has_method("apply_health_bonus"):
		enemy.apply_health_bonus(enemy_health_bonus_total)
	return enemy


func register_active_enemy(enemy: Node) -> void:
	if enemy == null:
		return
	if not active_enemies.has(enemy):
		active_enemies.append(enemy)
	if enemy.is_in_group("Boss") and not active_bosses.has(enemy):
		active_bosses.append(enemy)
	var exited_callback := _on_active_enemy_tree_exited.bind(enemy)
	if not enemy.tree_exited.is_connected(exited_callback):
		enemy.tree_exited.connect(exited_callback, CONNECT_ONE_SHOT)


func _on_active_enemy_tree_exited(enemy: Node) -> void:
	active_enemies.erase(enemy)
	active_bosses.erase(enemy)


func register_active_runtime_node(node: Node, registry: Array[Node]) -> void:
	if node == null:
		return
	if not registry.has(node):
		registry.append(node)
	var exited_callback := _on_active_runtime_node_tree_exited.bind(node, registry)
	if not node.tree_exited.is_connected(exited_callback):
		node.tree_exited.connect(exited_callback, CONNECT_ONE_SHOT)


func _on_active_runtime_node_tree_exited(node: Node, registry: Array[Node]) -> void:
	registry.erase(node)


func get_active_enemies() -> Array[Node]:
	return active_enemies


func get_active_exp_orbs() -> Array[Node]:
	return active_exp_orbs


func spawn_projectile(config: Dictionary, spawn_position: Vector2) -> Node:
	var projectile := acquire_projectile()
	projectile.global_position = spawn_position
	projectile.launch(config)
	register_active_projectile(projectile)
	return projectile


func acquire_projectile() -> Node:
	while not projectile_pool.is_empty():
		var projectile = projectile_pool.pop_back()
		if is_instance_valid(projectile):
			return projectile
	
	var projectile = PROJECTILE.instantiate()
	add_child(projectile)
	return projectile


func recycle_projectile(projectile: Node) -> void:
	if projectile == null or not is_instance_valid(projectile):
		return
	active_projectiles.erase(projectile)
	if projectile_pool.size() >= PROJECTILE_POOL_LIMIT:
		if projectile.has_method("prepare_for_pool"):
			projectile.prepare_for_pool()
		projectile.queue_free()
		return
	if projectile.get_parent() != self:
		projectile.reparent(self)
	if projectile.has_method("prepare_for_pool"):
		projectile.prepare_for_pool()
	projectile_pool.append(projectile)


func register_active_projectile(projectile: Node) -> void:
	if projectile == null:
		return
	if not active_projectiles.has(projectile):
		active_projectiles.append(projectile)


func get_boss_spawn_point() -> Vector2:
	var arena_rect: Rect2 = get_arena_rect().grow(-BOSS_ARENA_INSET)
	if arena_rect.size.x <= 0.0 or arena_rect.size.y <= 0.0:
		return get_arena_rect().get_center()
	
	for i in range(32):
		var candidate := Vector2(
			randf_range(arena_rect.position.x, arena_rect.end.x),
			randf_range(arena_rect.position.y, arena_rect.end.y)
		)
		if not get_camera_viewport_rect().has_point(candidate):
			return candidate
	
	return arena_rect.get_center()


func record_player_damage(amount: int) -> void:
	if amount <= 0:
		return
	
	total_damage_dealt += amount
	player_damage_events.append({
		"time": run_time,
		"damage": float(amount),
	})
	update_player_dps()


func record_player_damage_taken(amount: int) -> void:
	total_damage_taken += max(amount, 0)


func update_player_dps() -> void:
	var cutoff_time: float = run_time - PLAYER_DPS_WINDOW
	while not player_damage_events.is_empty() and float(player_damage_events[0].time) < cutoff_time:
		player_damage_events.pop_front()
	
	var total_damage: float = 0.0
	for event in player_damage_events:
		total_damage += float(event.damage)
	
	player_dps = total_damage / PLAYER_DPS_WINDOW


func update_low_health_upgrade_timer(delta: float) -> void:
	if player == null:
		return
	
	if player.get_health_ratio() <= LOW_HEALTH_UPGRADE_RATIO:
		low_health_upgrade_timer += delta
	else:
		low_health_upgrade_timer = 0.0


func get_average_spawn_enemy_hp() -> float:
	var weighted_variants := get_unlocked_weighted_entries(enemy_variant_catalog)
	var health_multiplier: float = 1.0 + enemy_health_bonus_total
	if weighted_variants.is_empty():
		return RED_ENEMY_BASE_HEALTH * health_multiplier
	
	var total_weight: float = 0.0
	var weighted_health: float = 0.0
	for entry in weighted_variants:
		var weight := float(entry.weight)
		total_weight += weight
		weighted_health += float(entry.config.get("health", RED_ENEMY_BASE_HEALTH)) * weight
	
	return weighted_health / max(total_weight, 0.001) * health_multiplier


func can_spawn_regular_enemy() -> bool:
	return has_enemy_pressure_room(0)


func has_enemy_pressure_room(reserved_slots: int = 0) -> bool:
	return get_active_enemy_count() + reserved_slots < get_active_enemy_cap()


func get_active_enemy_cap() -> int:
	var minutes: float = run_time / 60.0
	return clampi(
		BASE_ACTIVE_ENEMY_CAP + active_enemy_cap_bonus + int(floor(minutes * ACTIVE_ENEMY_CAP_GROWTH_PER_MINUTE)),
		BASE_ACTIVE_ENEMY_CAP,
		active_enemy_cap_limit
	)


func get_pressure_scaled_cap(ratio: float) -> int:
	return clampi(int(floor(float(get_active_enemy_cap()) * ratio)), 1, get_active_enemy_cap())


func get_ai_preferred_upgrade_id(displayed_upgrades: Array[String]) -> String:
	if displayed_upgrades.is_empty():
		return ""
	
	if player != null and player.piercing_level <= 0 and displayed_upgrades.has("piercing"):
		return "piercing"
	
	if player_dps < get_average_spawn_enemy_hp() * PLAYER_DPS_AVERAGE_HP_PRIORITY_MULTIPLIER:
		for upgrade_id in ["damage", "fire_rate", "splash"]:
			if displayed_upgrades.has(upgrade_id):
				return upgrade_id
	
	if low_health_upgrade_timer >= LOW_HEALTH_REGEN_PRIORITY_TIME and displayed_upgrades.has("regeneration"):
		return "regeneration"
	if player != null and player.health < player.max_health and displayed_upgrades.has("alloy_plating"):
		return "alloy_plating"
	
	return displayed_upgrades.pick_random()


func try_spawn_boss() -> void:
	if is_boss_alive():
		return
	if not has_enemy_pressure_room(BOSS_RESERVE_ENEMY_PRESSURE):
		return
	
	var boss_config := get_boss_config_to_spawn()
	spawn_enemy(boss_config.scene, _on_boss_defeated, boss_config)


func execute_boss_ability(boss: Node2D, module: Dictionary, phase_index: int) -> void:
	if boss == null or not is_instance_valid(boss):
		return
	
	match String(module.get("type", "")):
		"minion_call":
			spawn_boss_minions(boss.global_position, module, phase_index)
		"hazard_ring":
			spawn_boss_hazard_ring(boss.global_position, module, phase_index)
		"target_hazard":
			spawn_targeted_boss_hazard(module, phase_index)


func spawn_boss_minions(origin: Vector2, module: Dictionary, phase_index: int) -> void:
	var spawn_count: int = int(module.get("count", 2)) + phase_index * int(module.get("phase_count_bonus", 1))
	spawn_count = mini(spawn_count, 7)
	var minion_pressure_cap := get_pressure_scaled_cap(PRESSURE_MINION_SPAWN_RATIO)
	if get_active_enemy_count() >= minion_pressure_cap:
		return
	
	var minion_config := {
		"id": "boss_minion",
		"scene": ENEMY,
		"health": 14 + phase_index * 4,
		"speed": 72.0 + float(phase_index) * 8.0,
		"contact_damage": 1 + phase_index,
		"exp_drop_count": 1,
		"exp_drop_min_tier": BLUE_ORB_TIER,
		"color": Color(0.35, 0.55, 1.0, 1.0),
		"scale": 0.68,
		"movement_style": "weaver",
	}
	for i in range(spawn_count):
		if get_active_enemy_count() >= minion_pressure_cap:
			return
		var minion = spawn_enemy(ENEMY, _on_enemy_defeated, minion_config)
		var minion_position := origin + Vector2.RIGHT.rotated((TAU / float(spawn_count)) * float(i)) * randf_range(80.0, 128.0)
		minion.global_position = get_walkable_drop_position(minion_position, ENEMY_OBSTACLE_CLEARANCE)


func spawn_boss_hazard_ring(origin: Vector2, module: Dictionary, phase_index: int) -> void:
	var hazard_count: int = int(module.get("count", 5)) + phase_index * int(module.get("phase_count_bonus", 1))
	hazard_count = mini(hazard_count, 10)
	var ring_distance := float(module.get("ring_distance", 160.0)) + float(phase_index) * 24.0
	var angle_offset := randf() * TAU
	for i in range(hazard_count):
		var hazard_position := origin + Vector2.RIGHT.rotated(angle_offset + (TAU / float(hazard_count)) * float(i)) * ring_distance
		spawn_boss_hazard(hazard_position, float(module.get("radius", 72.0)), int(module.get("damage", 3)) + phase_index)


func spawn_targeted_boss_hazard(module: Dictionary, phase_index: int) -> void:
	if player == null:
		return
	var offset := Vector2.RIGHT.rotated(randf() * TAU) * randf_range(0.0, 42.0)
	spawn_boss_hazard(player.global_position + offset, float(module.get("radius", 64.0)) + float(phase_index) * 10.0, int(module.get("damage", 3)) + phase_index)


func process_map_gimmick(delta: float) -> void:
	if map_gimmick == "" or map_gimmick_interval <= 0.0:
		return
	map_gimmick_timer -= delta
	if map_gimmick_timer > 0.0:
		return
	map_gimmick_timer = map_gimmick_interval
	match map_gimmick:
		"crystal_storm":
			trigger_crystal_storm()
		"toxic_vents":
			trigger_toxic_vents()
		"void_collapse":
			trigger_void_collapse()
		"ghost_surge":
			trigger_ghost_surge()
		"laser_lattice":
			trigger_laser_lattice()
		"frost_lock":
			trigger_frost_lock()
		"ember_eruption":
			trigger_ember_eruption()
		"astral_collapse":
			trigger_astral_collapse()


func trigger_crystal_storm() -> void:
	if player == null:
		return
	var storm_count := 3 + int(run_time / 420.0)
	storm_count = clampi(storm_count, 3, 7)
	var base_angle := randf() * TAU
	for i in range(storm_count):
		var offset := Vector2.RIGHT.rotated(base_angle + TAU * float(i) / float(storm_count)) * randf_range(180.0, 360.0)
		spawn_boss_hazard(player.global_position + offset, 48.0, 2 + int(run_time / 900.0))
	spawn_particle_burst(self, player.global_position, 22, Color(0.45, 0.95, 1.0, 1.0), 210.0, 0.32, Vector2(4.0, 9.0), true)


func trigger_toxic_vents() -> void:
	var vent_count := 4 + int(run_time / 360.0)
	vent_count = clampi(vent_count, 4, 9)
	for i in range(vent_count):
		var hazard_position := get_walkable_drop_position(get_random_arena_position(96.0), ENEMY_OBSTACLE_CLEARANCE)
		spawn_boss_hazard(hazard_position, 58.0, 3 + int(run_time / 720.0))
	spawn_particle_burst(self, get_arena_rect().get_center(), 28, Color(0.64, 1.0, 0.2, 1.0), 300.0, 0.4, Vector2(5.0, 11.0), true)


func trigger_void_collapse() -> void:
	if player == null:
		return
	var pulse_count := 5 + int(run_time / 360.0)
	pulse_count = clampi(pulse_count, 5, 11)
	for i in range(pulse_count):
		var angle := randf() * TAU
		var distance := randf_range(110.0, 430.0)
		spawn_boss_hazard(player.global_position + Vector2.RIGHT.rotated(angle) * distance, 54.0, 4 + int(run_time / 600.0))
	if has_enemy_pressure_room(4):
		var void_config := {
			"id": "void_echo",
			"scene": ENEMY,
			"health": 34 + int(run_time / 30.0),
			"speed": 118.0,
			"contact_damage": 4,
			"exp_drop_count": 2,
			"exp_drop_min_tier": PURPLE_ORB_TIER,
			"color": Color(0.7, 0.34, 1.0, 1.0),
			"scale": 0.62,
			"movement_style": "weaver",
			"texture": "res://assets/visual/enemies/map5/null_mite.png",
		}
		for i in range(4):
			if not has_enemy_pressure_room(0):
				break
			spawn_enemy(ENEMY, _on_enemy_defeated, void_config)
	shake_camera(0.18, 4.5)


func trigger_ghost_surge() -> void:
	if player == null:
		return
	var surge_count := clampi(3 + int(run_time / 420.0), 3, 9)
	for i in range(surge_count):
		var offset := Vector2.RIGHT.rotated(randf() * TAU) * randf_range(120.0, 380.0)
		spawn_boss_hazard(player.global_position + offset, 50.0, 4 + int(run_time / 700.0))
	if has_enemy_pressure_room(3):
		var ghost_config := {
			"id": "grave_echo",
			"scene": ENEMY,
			"health": 50 + int(run_time / 28.0),
			"speed": 118.0,
			"contact_damage": 5,
			"exp_drop_count": 2,
			"exp_drop_min_tier": PURPLE_ORB_TIER,
			"color": Color(0.52, 0.62, 1.0, 1.0),
			"scale": 0.66,
			"movement_style": "orbiter",
			"texture": "res://assets/visual/enemies/variants/enemy_orbiter_cartoon.png",
		}
		for i in range(3):
			if not has_enemy_pressure_room(0):
				break
			spawn_enemy(ENEMY, _on_enemy_defeated, ghost_config)
	spawn_particle_burst(self, player.global_position, 24, Color(0.48, 0.62, 1.0, 1.0), 230.0, 0.32, Vector2(4.0, 8.0), true)


func trigger_laser_lattice() -> void:
	var arena_rect := get_arena_rect().grow(-120.0)
	var lane_count := clampi(4 + int(run_time / 500.0), 4, 8)
	for i in range(lane_count):
		var x := lerpf(arena_rect.position.x, arena_rect.end.x, (float(i) + 0.5) / float(lane_count))
		spawn_boss_hazard(Vector2(x, randf_range(arena_rect.position.y, arena_rect.end.y)), 42.0, 4 + int(run_time / 800.0))
	for i in range(lane_count / 2):
		var y := lerpf(arena_rect.position.y, arena_rect.end.y, (float(i) + 0.5) / max(float(lane_count / 2), 1.0))
		spawn_boss_hazard(Vector2(randf_range(arena_rect.position.x, arena_rect.end.x), y), 42.0, 4 + int(run_time / 800.0))
	spawn_particle_burst(self, get_arena_rect().get_center(), 26, Color(0.08, 0.95, 1.0, 1.0), 300.0, 0.28, Vector2(3.0, 7.0), true)


func trigger_frost_lock() -> void:
	if player == null:
		return
	var ring_count := clampi(5 + int(run_time / 520.0), 5, 10)
	for i in range(ring_count):
		var angle := TAU * float(i) / float(ring_count) + randf_range(-0.18, 0.18)
		var distance := randf_range(150.0, 330.0)
		spawn_boss_hazard(player.global_position + Vector2.RIGHT.rotated(angle) * distance, 56.0, 5 + int(run_time / 760.0))
	spawn_particle_burst(self, player.global_position, 30, Color(0.66, 0.9, 1.0, 1.0), 220.0, 0.4, Vector2(5.0, 10.0), true)


func trigger_ember_eruption() -> void:
	var eruption_count := clampi(6 + int(run_time / 420.0), 6, 12)
	for i in range(eruption_count):
		var hazard_position := get_walkable_drop_position(get_random_arena_position(80.0), ENEMY_OBSTACLE_CLEARANCE)
		spawn_boss_hazard(hazard_position, randf_range(50.0, 78.0), 6 + int(run_time / 650.0))
	spawn_particle_burst(self, get_arena_rect().get_center(), 36, Color(1.0, 0.34, 0.08, 1.0), 340.0, 0.38, Vector2(6.0, 12.0), true)
	shake_camera(0.16, 4.2)


func trigger_astral_collapse() -> void:
	if player == null:
		return
	var pulse_count := clampi(7 + int(run_time / 360.0), 7, 14)
	for i in range(pulse_count):
		var angle := randf() * TAU
		var distance := randf_range(90.0, 520.0)
		spawn_boss_hazard(player.global_position + Vector2.RIGHT.rotated(angle) * distance, 48.0 + float(i % 3) * 10.0, 6 + int(run_time / 620.0))
	if has_enemy_pressure_room(5):
		var echo_config := {
			"id": "astral_echo",
			"scene": ENEMY,
			"health": 72 + int(run_time / 24.0),
			"speed": 134.0,
			"contact_damage": 7,
			"exp_drop_count": 3,
			"exp_drop_min_tier": VIOLET_ORB_TIER,
			"color": Color(0.72, 0.48, 1.0, 1.0),
			"scale": 0.72,
			"movement_style": "weaver",
			"texture": "res://assets/visual/enemies/variants/enemy_zigzag_cartoon.png",
		}
		for i in range(5):
			if not has_enemy_pressure_room(0):
				break
			spawn_enemy(ENEMY, _on_enemy_defeated, echo_config)
	spawn_particle_burst(self, player.global_position, 38, Color(0.62, 0.35, 1.0, 1.0), 360.0, 0.42, Vector2(6.0, 12.0), true)
	shake_camera(0.18, 5.0)


func get_random_arena_position(inset: float = 0.0) -> Vector2:
	var arena_rect := get_arena_rect().grow(-inset)
	if arena_rect.size.x <= 0.0 or arena_rect.size.y <= 0.0:
		return get_arena_rect().get_center()
	return Vector2(randf_range(arena_rect.position.x, arena_rect.end.x), randf_range(arena_rect.position.y, arena_rect.end.y))


func spawn_boss_hazard(hazard_position: Vector2, radius: float, damage: int) -> void:
	if active_boss_hazards.size() >= MAX_ACTIVE_BOSS_HAZARDS:
		return
	var hazard = BOSS_HAZARD.instantiate()
	add_child(hazard)
	hazard.add_to_group("BossHazard")
	register_active_runtime_node(hazard, active_boss_hazards)
	hazard.global_position = clamp_position_to_arena(hazard_position)
	hazard.configure(radius, 0.85, 0.42, damage)


func clamp_position_to_arena(position_to_clamp: Vector2) -> Vector2:
	var arena_rect := get_arena_rect().grow(-BOSS_ARENA_INSET)
	if arena_rect.size.x <= 0.0 or arena_rect.size.y <= 0.0:
		arena_rect = get_arena_rect()
	return Vector2(
		clamp(position_to_clamp.x, arena_rect.position.x, arena_rect.end.x),
		clamp(position_to_clamp.y, arena_rect.position.y, arena_rect.end.y)
	)


func spawn_boss_phase_burst(boss_position: Vector2, phase_index: int) -> void:
	var burst_count := 36 + phase_index * 16
	spawn_particle_burst(self, boss_position, burst_count, Color(1.0, 0.08, 0.04, 1.0), 260.0, 0.45, Vector2(12.0, 20.0), true)


func is_boss_alive() -> bool:
	for boss in active_bosses:
		if is_instance_valid(boss):
			return true
	
	return false


func apply_enemy_health_bonus_to_active_enemies() -> void:
	for enemy in active_enemies:
		if is_instance_valid(enemy) and enemy.has_method("apply_health_bonus"):
			enemy.apply_health_bonus(enemy_health_bonus_total)


func get_scaled_enemy_contact_damage(base_damage: int) -> int:
	return maxi(1, int(round(float(base_damage) * enemy_damage_multiplier * get_active_run_event_multiplier("enemy_damage_multiplier"))))


func get_spawn_point() -> Vector2:
	var screen_size = get_viewport_rect().size
	var pos = player.global_position
	
	var left: float = pos.x - screen_size.x / 2
	var right: float = pos.x + screen_size.x / 2
	var up: float = pos.y - screen_size.y / 2
	var down: float = pos.y + screen_size.y / 2
	
	const OFFSET: int = 32
	
	var edge: int = randi() % 4 # 0 = up, 1 = down, 2 = left, 3 = right
	
	match edge:
		0: return Vector2(randf_range(left, right), up - OFFSET)
		1: return Vector2(randf_range(left, right), down + OFFSET)
		2: return Vector2(left - OFFSET, randf_range(up, down))
		3: return Vector2(right + OFFSET, randf_range(up, down))
	
	return Vector2.ZERO


func is_position_in_arena(pos: Vector2) -> bool:
	var arena_size: Vector2 = arena_mesh.mesh.size
	var arena_rect := Rect2(arena_mesh.global_position - arena_size / 2.0, arena_size)
	return arena_rect.has_point(pos)


func is_position_walkable(pos: Vector2, clearance: float = 0.0) -> bool:
	if map_layout and map_layout.has_method("is_walkable"):
		return bool(map_layout.is_walkable(pos, clearance))
	return is_position_in_arena(pos)


func get_walkable_drop_position(pos: Vector2, clearance: float = DROP_CLEARANCE) -> Vector2:
	if map_layout and map_layout.has_method("get_nearest_walkable_position"):
		return map_layout.get_nearest_walkable_position(pos, clearance)
	return pos


func resolve_actor_position(current_position: Vector2, target_position: Vector2, clearance: float = ENEMY_OBSTACLE_CLEARANCE) -> Vector2:
	if map_layout and map_layout.has_method("resolve_actor_step"):
		return map_layout.resolve_actor_step(current_position, target_position, clearance)
	return target_position


func get_arena_rect() -> Rect2:
	var arena_size: Vector2 = arena_mesh.mesh.size
	return Rect2(arena_mesh.global_position - arena_size / 2.0, arena_size)


func get_camera_viewport_rect() -> Rect2:
	var zoom := Vector2.ONE
	if player != null:
		var camera := player.get_node_or_null("Camera2D") as Camera2D
		if camera != null:
			zoom = camera.zoom
	var screen_size := get_viewport_rect().size / zoom
	return Rect2(player.global_position - screen_size / 2.0, screen_size)


func update_visibility_culling() -> void:
	var visible_rect := get_camera_viewport_rect().grow(VISIBILITY_CULL_MARGIN)
	for group_name in VISIBILITY_CULL_GROUPS:
		for node in get_visibility_cull_nodes(group_name):
			if node is CanvasItem and is_instance_valid(node):
				node.visible = visible_rect.has_point(node.global_position)


func get_visibility_cull_nodes(group_name: String) -> Array:
	match group_name:
		"Enemy":
			return active_enemies
		"ExpOrb":
			return active_exp_orbs
		"Projectile":
			return active_projectiles
	return get_tree().get_nodes_in_group(group_name)


func get_enemy_config_to_spawn() -> Dictionary:
	return pick_weighted_entry(get_unlocked_weighted_entries(enemy_variant_catalog))


func get_boss_config_to_spawn() -> Dictionary:
	var entries := get_unlocked_weighted_entries(boss_variant_catalog)
	if entries.size() > 1 and last_boss_variant_id != "":
		var filtered: Array[Dictionary] = []
		for entry in entries:
			if String(entry.config.get("id", "")) != last_boss_variant_id:
				filtered.append(entry)
		if not filtered.is_empty():
			entries = filtered
	var boss_config := pick_weighted_entry(entries)
	last_boss_variant_id = String(boss_config.get("id", ""))
	return boss_config


func apply_random_elite_affix(enemy_config: Dictionary) -> Dictionary:
	if get_active_enemy_count() >= get_pressure_scaled_cap(PRESSURE_SPLIT_SPAWN_RATIO):
		return enemy_config
	
	var elite_chance := get_elite_spawn_chance()
	if randf() > elite_chance:
		return enemy_config
	
	var affix := get_affix_config_to_apply()
	if affix.is_empty():
		return enemy_config
	
	return apply_affix_to_enemy_config(enemy_config, affix)


func apply_affix_to_enemy_config(enemy_config: Dictionary, affix: Dictionary) -> Dictionary:
	var modified_config := enemy_config.duplicate(true)
	modified_config["elite_affix"] = String(affix.id)
	modified_config["elite_name"] = String(affix.name)
	modified_config["health"] = maxi(1, int(ceil(float(modified_config.get("health", RED_ENEMY_BASE_HEALTH)) * float(affix.get("health_multiplier", 1.0)))))
	modified_config["speed"] = max(1.0, float(modified_config.get("speed", 50.0)) * float(affix.get("speed_multiplier", 1.0)))
	modified_config["contact_damage"] = maxi(1, int(ceil(float(modified_config.get("contact_damage", 1)) * float(affix.get("damage_multiplier", 1.0)))))
	modified_config["exp_drop_count"] = maxi(1, int(ceil(float(modified_config.get("exp_drop_count", 1)) * float(affix.get("exp_drop_multiplier", 1.0)))))
	modified_config["exp_drop_min_tier"] = clampi(int(modified_config.get("exp_drop_min_tier", BLUE_ORB_TIER)) + int(affix.get("exp_drop_min_tier_bonus", 0)), BLUE_ORB_TIER, VIOLET_ORB_TIER)
	modified_config["scale"] = float(modified_config.get("scale", 1.0)) * float(affix.get("scale_multiplier", 1.0))
	modified_config["color"] = blend_elite_color(modified_config.get("color", Color.WHITE) as Color, affix.get("color", Color.WHITE) as Color)
	
	var death_effect := String(affix.get("death_effect", ""))
	if death_effect != "":
		modified_config["death_payload"] = build_elite_death_payload(modified_config, affix)
	
	return modified_config


func get_elite_spawn_chance() -> float:
	if run_time < ELITE_CHANCE_START_SECONDS:
		return 0.0
	
	var progress: float = clamp((run_time - ELITE_CHANCE_START_SECONDS) / (ELITE_CHANCE_FULL_SECONDS - ELITE_CHANCE_START_SECONDS), 0.0, 1.0)
	return clamp(lerpf(0.02, ELITE_CHANCE_MAX, progress) * elite_chance_multiplier, 0.0, 0.45)


func get_affix_config_to_apply() -> Dictionary:
	var entries: Array[Dictionary] = []
	for affix in enemy_affix_catalog:
		if run_time < float(affix.get("unlock_seconds", 0.0)):
			continue
		entries.append({"config": affix, "weight": float(affix.get("weight", 0.0))})
	if entries.is_empty():
		return {}
	return pick_weighted_entry(entries)


func blend_elite_color(base_color: Color, affix_color: Color) -> Color:
	if base_color == Color.WHITE:
		return affix_color
	return base_color.lerp(affix_color, 0.48)


func build_elite_death_payload(enemy_config: Dictionary, affix: Dictionary) -> Dictionary:
	var effect := String(affix.get("death_effect", ""))
	match effect:
		"volatile":
			return {
				"effect": "volatile",
				"radius": float(affix.get("death_radius", 90.0)),
				"damage": float(affix.get("death_damage", 30.0)),
			}
		"split":
			return {
				"effect": "split",
				"count": int(affix.get("split_count", 2)),
				"scene": enemy_config.scene,
				"config": build_split_child_config(enemy_config, affix),
			}
	return {}


func build_split_child_config(enemy_config: Dictionary, affix: Dictionary) -> Dictionary:
	var child_config := enemy_config.duplicate(true)
	child_config.erase("death_payload")
	child_config.erase("elite_affix")
	child_config.erase("elite_name")
	child_config["id"] = "%s_split" % String(enemy_config.get("id", "enemy"))
	child_config["health"] = int(affix.get("split_health", 8))
	child_config["speed"] = float(affix.get("split_speed", 82.0))
	child_config["contact_damage"] = 1
	child_config["exp_drop_count"] = 1
	child_config["exp_drop_min_tier"] = BLUE_ORB_TIER
	child_config["scale"] = max(float(enemy_config.get("scale", 1.0)) * 0.58, 0.42)
	child_config["color"] = Color(0.92, 0.38, 1.0, 1.0)
	child_config["movement_style"] = "weaver"
	return child_config


func get_unlocked_weighted_entries(catalog: Array[Dictionary]) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for config in catalog:
		if not is_catalog_entry_available_for_selected_map(config):
			continue
		var unlock_seconds := float(config.get("unlock_seconds", 0.0))
		if run_time < unlock_seconds:
			continue
		
		var minutes_since_unlock: float = max((run_time - unlock_seconds) / 60.0, 0.0)
		var weight: float = float(config.get("weight", config.get("base_weight", 0.0)))
		weight += minutes_since_unlock * float(config.get("growth_per_minute", 0.0))
		weight = clamp(weight, float(config.get("min_weight", 0.0)), float(config.get("max_weight", weight)))
		weight *= get_map_entry_weight_multiplier(config)
		if weight <= 0.0:
			continue
		
		entries.append({"config": config, "weight": weight})
	
	return entries


func is_catalog_entry_available_for_selected_map(config: Dictionary) -> bool:
	var maps: Array = config.get("maps", []) as Array
	if maps.is_empty():
		return true
	return maps.has(selected_map_id)


func get_map_entry_weight_multiplier(config: Dictionary) -> float:
	var maps: Array = config.get("maps", []) as Array
	if maps.has(selected_map_id):
		return 1.0
	match selected_map_id:
		"map2":
			return 0.42
		"map3":
			return 0.32
		"map4":
			return 0.25
		"map5":
			return 0.18
		"map6":
			return 0.16
		"map7":
			return 0.14
		"map8":
			return 0.13
		"map9":
			return 0.12
		"map10":
			return 0.1
	return 1.0


func pick_weighted_entry(weighted_entries: Array[Dictionary]) -> Dictionary:
	if weighted_entries.is_empty():
		return enemy_variant_catalog[0]
	
	var total_weight: float = 0.0
	for entry in weighted_entries:
		total_weight += float(entry.weight)
	
	var roll := randf() * total_weight
	for entry in weighted_entries:
		roll -= float(entry.weight)
		if roll <= 0.0:
			return entry.config
	
	return weighted_entries.back().config


func _on_enemy_defeated(enemy_position: Vector2, exp_drop_count: int = 1, exp_drop_min_tier: int = BLUE_ORB_TIER, death_payload: Dictionary = {}) -> void:
	enemies_defeated += 1
	if String(death_payload.get("elite_affix", "")) != "":
		elites_defeated += 1
	var mass_damage_active := dynamite_blast_active or splash_blast_active
	
	if not mass_damage_active:
		spawn_enemy_death_burst.call_deferred(enemy_position)
		apply_elite_death_payload.call_deferred(enemy_position, death_payload)
	
	if mass_damage_active:
		queue_exp_drops(enemy_position, exp_drop_count, exp_drop_min_tier)
	else:
		call_deferred("queue_exp_drops", enemy_position, exp_drop_count, exp_drop_min_tier)
	
	if not mass_damage_active:
		try_drop_dynamite.call_deferred(enemy_position)
		try_drop_wrench.call_deferred(enemy_position)
	if player != null and player.has_method("try_recycler_heal"):
		player.try_recycler_heal(false)


func apply_elite_death_payload(enemy_position: Vector2, death_payload: Dictionary) -> void:
	if death_payload.is_empty():
		return
	
	match String(death_payload.get("effect", "")):
		"volatile":
			apply_volatile_elite_death(enemy_position, float(death_payload.get("radius", 90.0)), float(death_payload.get("damage", 30.0)))
		"split":
			spawn_split_elite_children(enemy_position, death_payload)


func apply_volatile_elite_death(enemy_position: Vector2, radius: float, damage: float) -> void:
	shake_camera(0.16, 3.5)
	splash_blast_active = true
	for enemy in active_enemies:
		if not is_instance_valid(enemy) or enemy.global_position.distance_to(enemy_position) > radius:
			continue
		if enemy.has_method("hit"):
			enemy.hit(damage, false)
	splash_blast_active = false
	spawn_particle_burst.call_deferred(self, enemy_position, 18, Color(1.0, 0.22, 0.08, 1.0), 230.0, 0.24, Vector2(8.0, 14.0), true)


func spawn_split_elite_children(enemy_position: Vector2, death_payload: Dictionary) -> void:
	var child_count: int = mini(int(death_payload.get("count", 2)), 3)
	if child_count <= 0:
		return
	var split_pressure_cap := mini(get_pressure_scaled_cap(PRESSURE_SPLIT_SPAWN_RATIO), ELITE_SPLIT_ACTIVE_ENEMY_CAP)
	if get_active_enemy_count() >= split_pressure_cap:
		return
	
	var child_scene: PackedScene = death_payload.get("scene", ENEMY) as PackedScene
	var child_config: Dictionary = death_payload.get("config", {}) as Dictionary
	for i in range(child_count):
		if get_active_enemy_count() >= split_pressure_cap:
			return
		var child = spawn_enemy(child_scene, _on_enemy_defeated, child_config)
		var child_position := enemy_position + Vector2.RIGHT.rotated((TAU / float(child_count)) * float(i) + randf_range(-0.35, 0.35)) * randf_range(14.0, 28.0)
		child.global_position = get_walkable_drop_position(child_position, ENEMY_OBSTACLE_CLEARANCE)


func get_active_enemy_count() -> int:
	return active_enemies.size()


func _on_boss_defeated(enemy_position: Vector2, exp_drop_count: int = 30, exp_drop_min_tier: int = BLUE_ORB_TIER) -> void:
	enemies_defeated += 1
	bosses_defeated += 1
	shake_camera(0.34, 8.0)
	exp_drop_count = int(ceil(float(exp_drop_count) * boss_exp_multiplier))
	var mass_damage_active := dynamite_blast_active or splash_blast_active
	
	spawn_boss_death_burst.call_deferred(enemy_position)
	
	if mass_damage_active:
		queue_boss_exp_drops(enemy_position, exp_drop_count, exp_drop_min_tier)
	else:
		call_deferred("queue_boss_exp_drops", enemy_position, exp_drop_count, exp_drop_min_tier)
	
	if not mass_damage_active:
		try_drop_dynamite.call_deferred(enemy_position)
		try_drop_wrench.call_deferred(enemy_position)
	if player != null and player.has_method("try_recycler_heal"):
		player.try_recycler_heal(true)


func shake_camera(duration: float, strength: float) -> void:
	if player == null:
		return
	var camera := player.get_node_or_null("Camera2D")
	if camera != null and camera.has_method("start_shake"):
		camera.start_shake(duration, strength)


func queue_exp_drops(enemy_position: Vector2, drop_count: int, exp_drop_min_tier: int = BLUE_ORB_TIER) -> void:
	for i in range(drop_count):
		queued_exp_drops.append({
		"position": get_exp_drop_position(enemy_position, i, drop_count),
		"min_tier": exp_drop_min_tier
		})


func queue_boss_exp_drops(enemy_position: Vector2, drop_count: int, exp_drop_min_tier: int = BLUE_ORB_TIER) -> void:
	for i in range(drop_count):
		var angle := randf() * TAU
		var distance := randf_range(16.0, 96.0)
		queued_exp_drops.append({
			"position": enemy_position + Vector2.RIGHT.rotated(angle) * distance,
			"min_tier": exp_drop_min_tier
		})


func get_exp_drop_position(enemy_position: Vector2, drop_index: int, drop_count: int) -> Vector2:
	if drop_count <= 1:
		return enemy_position
	
	var angle: float = TAU * float(drop_index) / float(drop_count)
	var offset: Vector2 = Vector2.RIGHT.rotated(angle) * 12.0
	return enemy_position + offset


func _spawn_exp_orb(drop_data: Dictionary) -> void:
	if not is_inside_tree():
		return
	
	var enemy_position: Vector2 = get_walkable_drop_position(drop_data.position, DROP_CLEARANCE)
	var min_tier: int = drop_data.get("min_tier", BLUE_ORB_TIER)
	var orb_data := get_random_exp_orb_data(min_tier)
	if active_exp_orbs.size() >= MAX_ACTIVE_EXP_ORBS:
		merge_exp_into_existing_orb(orb_data.value)
		return
	
	var exp_orb = EXP_ORB.instantiate()
	add_child(exp_orb)
	register_active_runtime_node(exp_orb, active_exp_orbs)
	exp_orb.global_position = enemy_position
	exp_orb.configure(int(ceil(float(orb_data.value) * exp_value_multiplier * get_active_run_event_multiplier("exp_value_multiplier"))), orb_data.radius, orb_data.texture, orb_data.get("visual_scale", 1.0))
	
	if magnet_effect_timer > 0.0:
		exp_orb.set_magnet_active(true, player)


func get_random_exp_orb_data(min_tier: int = BLUE_ORB_TIER) -> Dictionary:
	if min_tier >= VIOLET_ORB_TIER:
		return get_violet_exp_orb_data()
	
	if min_tier >= ORANGE_ORB_TIER:
		var advanced_total: float = violet_orb_drop_chance + purple_orb_drop_chance + orange_orb_drop_chance
		if advanced_total <= 0.0:
			return {"value": 4, "radius": 10.0, "texture": BLUE_EXP_CRYSTAL, "visual_scale": 0.31}
		
		var advanced_roll := randf() * advanced_total
		if advanced_roll < violet_orb_drop_chance:
			return get_violet_exp_orb_data()
		if advanced_roll < violet_orb_drop_chance + purple_orb_drop_chance:
			return {"value": 9, "radius": 13.0, "texture": RED_EXP_CRYSTAL, "visual_scale": 0.41}
		
		return {"value": 4, "radius": 10.0, "texture": BLUE_EXP_CRYSTAL, "visual_scale": 0.31}
	
	var orb_roll := randf()
	if orb_roll < violet_orb_drop_chance:
		return get_violet_exp_orb_data()
	elif orb_roll < violet_orb_drop_chance + purple_orb_drop_chance:
		return {"value": 9, "radius": 13.0, "texture": RED_EXP_CRYSTAL, "visual_scale": 0.41}
	elif orb_roll < violet_orb_drop_chance + purple_orb_drop_chance + orange_orb_drop_chance:
		return {"value": 4, "radius": 10.0, "texture": BLUE_EXP_CRYSTAL, "visual_scale": 0.31}
	
	return {"value": 2, "radius": 8.0, "texture": GREEN_EXP_CRYSTAL, "visual_scale": 0.25}


func get_violet_exp_orb_data() -> Dictionary:
	return {"value": 18, "radius": 15.0, "texture": PURPLE_EXP_CRYSTAL, "visual_scale": 0.47}


func merge_exp_into_existing_orb(additional_value: int) -> void:
	if active_exp_orbs.is_empty():
		return
	
	var target_orb = active_exp_orbs.pick_random()
	if is_instance_valid(target_orb) and target_orb.has_method("merge_exp"):
		target_orb.merge_exp(additional_value)


func process_queued_exp_drops() -> void:
	var drops_to_spawn: int = mini(EXP_DROPS_PER_FRAME, queued_exp_drops.size())
	for i in range(drops_to_spawn):
		_spawn_exp_orb(queued_exp_drops.pop_front())


func update_exp_orb_drop_chances() -> void:
	var moved_chance: float = 0.0
	
	if run_time >= VIOLET_ORB_START_TIME:
		shift_drop_chance_to_violet(0.01)
		return
	
	if run_time < PURPLE_ORB_START_TIME:
		moved_chance = min(0.01, blue_orb_drop_chance)
		blue_orb_drop_chance -= moved_chance
		orange_orb_drop_chance += moved_chance
		return
	
	moved_chance = min(0.01, blue_orb_drop_chance)
	if moved_chance > 0.0:
		blue_orb_drop_chance -= moved_chance
		purple_orb_drop_chance += moved_chance
		return
	
	moved_chance = min(0.01, orange_orb_drop_chance)
	orange_orb_drop_chance -= moved_chance
	purple_orb_drop_chance += moved_chance


func shift_drop_chance_to_violet(amount: float) -> void:
	var available_chance := blue_orb_drop_chance + orange_orb_drop_chance + purple_orb_drop_chance
	var moved_chance: float = min(amount, available_chance)
	if moved_chance <= 0.0:
		return
	
	drain_drop_chance_proportionally(moved_chance, available_chance)
	violet_orb_drop_chance += moved_chance


func drain_drop_chance_proportionally(amount: float, available_chance: float) -> void:
	if available_chance <= 0.0:
		return
	
	var blue_drain: float = min(blue_orb_drop_chance, amount * blue_orb_drop_chance / available_chance)
	var orange_drain: float = min(orange_orb_drop_chance, amount * orange_orb_drop_chance / available_chance)
	var purple_drain: float = min(purple_orb_drop_chance, amount - blue_drain - orange_drain)
	
	blue_orb_drop_chance -= blue_drain
	orange_orb_drop_chance -= orange_drain
	purple_orb_drop_chance -= purple_drain
	
	var remainder: float = amount - blue_drain - orange_drain - purple_drain
	if remainder > 0.0:
		var final_blue_drain: float = min(blue_orb_drop_chance, remainder)
		blue_orb_drop_chance -= final_blue_drain
		remainder -= final_blue_drain
	
	if remainder > 0.0:
		var final_orange_drain: float = min(orange_orb_drop_chance, remainder)
		orange_orb_drop_chance -= final_orange_drain
		remainder -= final_orange_drain
	
	if remainder > 0.0:
		purple_orb_drop_chance = max(purple_orb_drop_chance - remainder, 0.0)


func try_drop_dynamite(enemy_position: Vector2) -> void:
	if dynamite_pickup_pool == null or dynamite_pickup_pool.is_active:
		return
	
	if randf() > dynamite_drop_chance:
		return
	
	if not is_position_in_arena(enemy_position):
		return
	
	dynamite_pickup_pool.activate(get_walkable_drop_position(enemy_position, DROP_CLEARANCE))


func try_drop_wrench(enemy_position: Vector2) -> void:
	if randf() > wrench_drop_chance:
		return
	
	if not is_position_in_arena(enemy_position):
		return
	
	var wrench_pickup := get_available_wrench_pickup()
	if wrench_pickup == null:
		return
	
	wrench_pickup.activate(get_walkable_drop_position(enemy_position, DROP_CLEARANCE))


func get_available_wrench_pickup() -> Node:
	for wrench_pickup in wrench_pickup_pool:
		if is_instance_valid(wrench_pickup) and not wrench_pickup.is_active:
			return wrench_pickup
	
	return null


func debug_spawn_dynamite() -> void:
	if dynamite_pickup_pool == null or dynamite_pickup_pool.is_active:
		return
	
	var spawn_position := player.global_position + Vector2(96.0, 0.0)
	var arena_rect := get_arena_rect()
	spawn_position.x = clamp(spawn_position.x, arena_rect.position.x + 16.0, arena_rect.end.x - 16.0)
	spawn_position.y = clamp(spawn_position.y, arena_rect.position.y + 16.0, arena_rect.end.y - 16.0)
	dynamite_pickup_pool.activate(get_walkable_drop_position(spawn_position, DROP_CLEARANCE))


func spawn_enemy_death_burst(enemy_position: Vector2) -> void:
	spawn_particle_burst(self, enemy_position, 14, Color(1.0, 0.36, 0.08, 1.0), 230.0, 0.28, Vector2(7.0, 13.0), true)
	spawn_particle_burst(self, enemy_position, 8, Color(1.0, 0.92, 0.25, 1.0), 170.0, 0.18, Vector2(3.0, 6.0), true)


func spawn_boss_death_burst(enemy_position: Vector2) -> void:
	dynamite_flash.color = Color(1.0, 0.62, 0.18, 0.58)
	spawn_particle_burst(self, enemy_position, 80, Color(1.0, 0.22, 0.04, 1), 330.0, 0.68, Vector2(24.0, 38.0), true)
	spawn_particle_burst(self, enemy_position, 42, Color(0.25, 0.92, 1.0, 1), 245.0, 0.48, Vector2(10.0, 20.0), true)


func _on_player_damaged(player_position: Vector2) -> void:
	dynamite_flash.color = Color(1.0, 0.05, 0.02, 0.22)
	spawn_particle_burst(self, player_position, 50, Color(1, 0.06, 0.02, 1), 220.0, 0.42, Vector2(2.0, 5.0), false)


func spawn_exp_pickup_burst() -> void:
	var burst_position: Vector2 = exp_bar.get_fill_end_global_position()
	spawn_particle_burst($CanvasLayer, burst_position, 18, Color(1, 0.95, 0.08, 1), 220.0, 0.28, Vector2(2.0, 5.0), false)


func spawn_projectile_hit_feedback(hit_position: Vector2, is_final_hit: bool, is_splash_hit: bool) -> void:
	if projectile_hit_feedback_this_frame >= MAX_PROJECTILE_HIT_FEEDBACK_PER_FRAME:
		return
	projectile_hit_feedback_this_frame += 1
	var spark_count := 5
	var spark_size := Vector2(1.4, 3.2)
	var spark_speed := 95.0
	var spark_color := Color(1.0, 0.78, 0.16, 1.0)
	if is_final_hit:
		spark_count += 3
		spark_speed += 45.0
	if is_splash_hit:
		spark_count += 5
		spark_size = Vector2(2.8, 6.0)
		spark_speed += 90.0
		spark_color = Color(1.0, 0.42, 0.08, 1.0)
	spawn_particle_burst(self, hit_position, spark_count, spark_color, spark_speed, 0.16, spark_size, true)
	if is_splash_hit and is_final_hit:
		shake_camera(0.08, 1.6)


func spawn_particle_burst(parent: Node, burst_position: Vector2, count: int, color: Color, speed: float, duration: float, size_range: Vector2, shrink: bool) -> void:
	if active_particle_bursts.size() >= MAX_ACTIVE_PARTICLE_BURSTS:
		return
	var burst = acquire_particle_burst(parent)
	burst.add_to_group("ParticleBurst")
	if not active_particle_bursts.has(burst):
		active_particle_bursts.append(burst)
	burst.global_position = burst_position
	burst.configure(count, color, speed, duration, size_range, shrink)


func acquire_particle_burst(parent: Node) -> Node:
	while not particle_burst_pool.is_empty():
		var burst = particle_burst_pool.pop_back()
		if is_instance_valid(burst):
			if burst.get_parent() != parent:
				burst.reparent(parent)
			return burst
	
	var burst = PARTICLE_BURST.instantiate()
	parent.add_child(burst)
	return burst


func recycle_particle_burst(burst: Node) -> void:
	if burst == null or not is_instance_valid(burst):
		return
	active_particle_bursts.erase(burst)
	if particle_burst_pool.size() >= PARTICLE_BURST_POOL_LIMIT:
		burst.queue_free()
		return
	particle_burst_pool.append(burst)


func show_damage_number(world_position: Vector2, damage: int) -> void:
	if damage_numbers_this_frame >= MAX_DAMAGE_NUMBERS_PER_FRAME:
		return
	damage_numbers_this_frame += 1
	damage_number_pool.show_damage(world_position, damage)


func show_healing_popup(world_position: Vector2, healed_amount: int) -> void:
	var popup = HEALING_POPUP.instantiate()
	add_child(popup)
	popup.configure(world_position, healed_amount)
	spawn_particle_burst(self, world_position, 12, Color(0.38, 1.0, 0.54, 1.0), 150.0, 0.22, Vector2(2.0, 5.0), true)


func _spawn_splash_area(splash_position: Vector2, splash_radius: float, damage: float, enemies: Array[Area2D]) -> void:
	if active_splash_areas.size() >= MAX_ACTIVE_SPLASH_AREAS:
		return
	var splash = SPLASH_AREA.instantiate()
	add_child(splash)
	splash.add_to_group("SplashArea")
	register_active_runtime_node(splash, active_splash_areas)
	splash.global_position = splash_position
	var is_mass_splash := enemies.size() >= MASS_SPLASH_ENEMY_THRESHOLD
	splash_blast_active = is_mass_splash
	splash.configure(splash_radius, damage, enemies, not is_mass_splash)
	splash_blast_active = false
	if enemies.size() >= 4 or splash_radius >= 90.0:
		spawn_particle_burst(self, splash_position, 14, Color(1.0, 0.72, 0.18, 1.0), 210.0, 0.22, Vector2(4.0, 9.0), true)
	if is_mass_splash:
		shake_camera(0.14, 3.0)


func activate_dynamite() -> void:
	shake_camera(0.28, 7.0)
	dynamite_flash.color = Color(1.0, 0.92, 0.25, 0.85)
	var enemies := active_enemies.duplicate()
	dynamite_blast_active = true
	for enemy in enemies:
		if is_instance_valid(enemy) and is_position_in_arena(enemy.global_position) and enemy.has_method("hit"):
			var dynamite_damage := DYNAMITE_BOSS_DAMAGE if enemy.is_in_group("Boss") else DYNAMITE_DAMAGE
			enemy.hit(dynamite_damage, false)
	dynamite_blast_active = false


func activate_magnet_effect() -> void:
	magnet_effect_timer = MAGNET_DURATION
	set_exp_orbs_magnet_active(true)


func set_exp_orbs_magnet_active(active: bool) -> void:
	for exp_orb in active_exp_orbs:
		if is_instance_valid(exp_orb) and exp_orb.has_method("set_magnet_active"):
			exp_orb.set_magnet_active(active, player if active else null)


func try_spawn_magnet_pickup() -> void:
	if magnet_pickup_pool == null or magnet_pickup_pool.is_active:
		return
	
	var spawn_position := get_offscreen_arena_spawn_point()
	if spawn_position == Vector2.INF:
		return
	
	magnet_pickup_pool.activate(spawn_position)


func try_spawn_supply_box() -> void:
	if randf() > supply_box_spawn_chance:
		return
	
	var spawn_position := get_offscreen_arena_spawn_point()
	var supply_box_scene := SUPPLY_BOX_BLUE if randf() < BLUE_SUPPLY_BOX_CHANCE else SUPPLY_BOX_GREEN
	spawn_supply_box_at_position(supply_box_scene, spawn_position)


func spawn_supply_box_at_position(supply_box_scene: PackedScene, spawn_position: Vector2) -> void:
	if spawn_position == Vector2.INF:
		return
	var supply_box = supply_box_scene.instantiate()
	add_child(supply_box)
	supply_box.global_position = get_walkable_drop_position(spawn_position, DROP_CLEARANCE)


func debug_spawn_supply_box(supply_box_scene: PackedScene, offset: Vector2) -> void:
	var spawn_position := player.global_position + offset
	var arena_rect := get_arena_rect()
	spawn_position.x = clamp(spawn_position.x, arena_rect.position.x + 32.0, arena_rect.end.x - 32.0)
	spawn_position.y = clamp(spawn_position.y, arena_rect.position.y + 32.0, arena_rect.end.y - 32.0)
	
	var supply_box = supply_box_scene.instantiate()
	add_child(supply_box)
	supply_box.global_position = get_walkable_drop_position(spawn_position, DROP_CLEARANCE)


func get_offscreen_arena_spawn_point() -> Vector2:
	var arena_rect := get_arena_rect()
	var camera_rect := get_camera_viewport_rect()
	
	for i in range(100):
		var candidate := Vector2(
			randf_range(arena_rect.position.x, arena_rect.end.x),
			randf_range(arena_rect.position.y, arena_rect.end.y)
		)
		
		if not camera_rect.has_point(candidate) and is_position_walkable(candidate, DROP_CLEARANCE):
			return candidate
	
	return Vector2.INF


func _on_player_exp_changed(current_exp: int, required_exp: int, level: int) -> void:
	var progress := 0.0
	if required_exp > 0:
		progress = clamp(float(current_exp) / float(required_exp), 0.0, 1.0)
	
	exp_bar.set_progress(progress)
	exp_bar.set_label_text("Level %s  %s/%s" % [level, current_exp, required_exp])


func _on_player_health_changed(current_health: int, maximum_health: int) -> void:
	var progress := 0.0
	if maximum_health > 0:
		progress = clamp(float(current_health) / float(maximum_health), 0.0, 1.0)
	
	hp_bar.set_progress(progress)
	hp_bar.set_label_text("HP %s/%s" % [current_health, maximum_health])


func update_stats_label() -> void:
	if player == null:
		return
	
	var regen_per_second := 0.0
	if player.regeneration_interval > 0.0:
		regen_per_second = float(player.regeneration_amount) / player.regeneration_interval
	
	var exp_multiplier_percent := int(round((1.0 + float(player.exp_bonus_level) * 0.25) * 100.0))
	var armor_percent := int(round(player.get_armor_damage_reduction() * 100.0)) if player.has_method("get_armor_damage_reduction") else 0
	var crit_percent: int = int(round(player.get_crit_chance() * 100.0)) if player.has_method("get_crit_chance") else 0
	var projectile_speed: float = player.get_projectile_speed() if player.has_method("get_projectile_speed") else 500.0
	var power_percent := int(round(player.get_power_damage_multiplier() * 100.0)) if player.has_method("get_power_damage_multiplier") else 100
	stats_label.text = "Tank: %s\nDamage: %.1f\nPower: %s%%\nDPS: %.1f / %.1f HP\nPressure: %s/%s\nEvent: %s\nBarbed Wire: %.0f%% / 0.5s\nSplash Radius: %.0f px\nCannons: %s\nMove Speed: %.0f\nFire Rate: %.3fs\nProjectile Speed: %.0f\nCrit Chance: %s%%\nArmor: %s%%\nRegen: %.3f HP/s\nEXP Mult: %s%%" % [
		player.selected_tank_name,
		player.attack_damage,
		power_percent,
		player_dps,
		get_average_spawn_enemy_hp(),
		get_active_enemy_count(),
		get_active_enemy_cap(),
		get_run_event_status_text(),
		float(player.barbed_wire_level) * 33.0,
		player.get_splash_radius(),
		1 + player.cannon_level,
		player.speed,
		player.fire_interval,
		projectile_speed,
		crit_percent,
		armor_percent,
		regen_per_second,
		exp_multiplier_percent
	]


func get_run_summary_text(unlocked_messages: Array[String]) -> String:
	var lines: Array[String] = [
		"VICTORY" if run_was_victory else "RUN COMPLETE",
		"Tank: %s  Map: %s  Level: %s  Time: %s" % [player.selected_tank_name, selected_map_name, player.level, get_formatted_run_time()],
		"Seed: %s" % run_seed_text,
		"Run modifiers: %s" % run_modifier_summary,
		"Run events: %s" % get_run_event_summary_text(),
		"",
		"Combat",
		"Kills: %s  Elites: %s  Bosses: %s" % [enemies_defeated, elites_defeated, bosses_defeated],
		"Damage dealt: %s  Damage taken: %s  DPS: %.1f" % [total_damage_dealt, total_damage_taken, player_dps],
		"Final pressure: %s/%s  Skipped spawns: %s" % [get_active_enemy_count(), get_active_enemy_cap(), spawn_skips_from_pressure],
		"",
		"Build",
		get_build_summary_text(),
	]
	var evolution_names: Array[String] = []
	if player.has_method("get_active_evolution_names"):
		evolution_names = player.get_active_evolution_names()
	if not evolution_names.is_empty():
		lines.append("Evolutions: %s" % ", ".join(evolution_names))
	lines.append("")
	lines.append(get_unlock_manager().get_progress_report(unlocked_messages))
	return "\n".join(lines)


func get_build_summary_text() -> String:
	var entries := get_ranked_build_entries()
	var evolution_names: Array[String] = []
	if player.has_method("get_active_evolution_names"):
		evolution_names = player.get_active_evolution_names()
	
	if entries.is_empty() and evolution_names.is_empty():
		return "No upgrades"
	
	var top_entries: Array[String] = []
	for i in range(mini(4, entries.size())):
		top_entries.append("%s %s" % [String(entries[i].name), int(entries[i].level)])
	
	if not evolution_names.is_empty():
		top_entries.append("Evolved: %s" % ", ".join(evolution_names.slice(0, 3)))
	return ", ".join(top_entries)


func get_build_level_snapshot() -> Dictionary:
	return {
		"damage": player.damage_level,
		"fire_rate": player.fire_rate_level,
		"speed": player.speed_level,
		"armor": player.armor_level,
		"cannon": player.cannon_level,
		"targeting_array": player.targeting_array_level,
		"accelerator": player.accelerator_level,
		"alloy_plating": player.alloy_plating_level,
		"recycler": player.recycler_level,
		"payload_rack": player.payload_rack_level,
		"reactive_shield": player.reactive_shield_level,
		"gyro_stabilizer": player.gyro_stabilizer_level,
		"rapid_loader": player.rapid_loader_level,
		"high_caliber": player.high_caliber_level,
		"nanobots": player.nanobots_level,
		"kinetic_treads": player.kinetic_treads_level,
		"ammo_synthesizer": player.ammo_synthesizer_level,
		"shatter_rounds": player.shatter_rounds_level,
		"phase_core": player.phase_core_level,
		"capacitor_bank": player.capacitor_bank_level,
		"salvage_magnet": player.salvage_magnet_level,
		"emergency_repairs": player.emergency_repairs_level,
		"combustion_mix": player.combustion_mix_level,
		"heat_sinks": player.heat_sinks_level,
		"overclocked_barrel": player.overclocked_barrel_level,
		"rail_stabilizer": player.rail_stabilizer_level,
		"missile_guidance": player.missile_guidance_level,
		"ordnance_bay": player.ordnance_bay_level,
		"field_amplifier": player.field_amplifier_level,
		"volt_coils": player.volt_coils_level,
		"gravity_anchor": player.gravity_anchor_level,
		"repair_drones": player.repair_drones_level,
		"crystal_lens": player.crystal_lens_level,
		"munition_printer": player.munition_printer_level,
		"stabilized_chassis": player.stabilized_chassis_level,
		"vector_thrusters": player.vector_thrusters_level,
		"impact_fuse": player.impact_fuse_level,
		"armor_piercers": player.armor_piercers_level,
		"weakpoint_scanner": player.weakpoint_scanner_level,
		"med_pump": player.med_pump_level,
		"orbit_gears": player.orbit_gears_level,
		"mine_dispenser": player.mine_dispenser_level,
		"drone_command": player.drone_command_level,
		"lucky_core": player.lucky_core_level,
		"piercing": player.piercing_level,
		"splash": player.splash_level,
		"magnet": player.magnet_level,
		"exp": player.exp_bonus_level,
		"barbed_wire": player.barbed_wire_level,
		"landmine": player.landmine_level,
		"circular_saw": player.circular_saw_level,
		"footsoldier": player.footsoldier_level,
		"shock_field": player.shock_field_level,
		"artillery": player.artillery_level,
		"drone_swarm": player.drone_swarm_level,
		"oil_slick": player.oil_slick_level,
		"freeze_pulse": player.freeze_pulse_level,
		"chain_lightning": player.chain_lightning_level,
		"guardian_satellite": player.guardian_satellite_level,
		"overdrive_core": player.overdrive_core_level,
		"flame_wave": player.flame_wave_level,
		"repair_beacon": player.repair_beacon_level,
		"missile_pod": player.missile_pod_level,
		"gravity_well": player.gravity_well_level,
		"railgun_orbiter": player.railgun_orbiter_level,
		"tesla_pylon": player.tesla_pylon_level,
		"nanite_cloud": player.nanite_cloud_level,
		"ricochet_rounds": player.ricochet_rounds_level,
		"chrono_burst": player.chrono_burst_level,
	}


func get_ranked_build_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	add_build_entry(entries, "Damage", player.damage_level)
	add_build_entry(entries, "Fire Rate", player.fire_rate_level)
	add_build_entry(entries, "Speed", player.speed_level)
	add_build_entry(entries, "Armor", player.armor_level)
	add_build_entry(entries, "Cannon", player.cannon_level)
	add_build_entry(entries, "Targeting Array", player.targeting_array_level)
	add_build_entry(entries, "Accelerator", player.accelerator_level)
	add_build_entry(entries, "Alloy Plating", player.alloy_plating_level)
	add_build_entry(entries, "Recycler", player.recycler_level)
	add_build_entry(entries, "Payload Rack", player.payload_rack_level)
	add_build_entry(entries, "Reactive Shield", player.reactive_shield_level)
	add_build_entry(entries, "Gyro Stabilizer", player.gyro_stabilizer_level)
	add_build_entry(entries, "Rapid Loader", player.rapid_loader_level)
	add_build_entry(entries, "High Caliber", player.high_caliber_level)
	add_build_entry(entries, "Nanobots", player.nanobots_level)
	add_build_entry(entries, "Kinetic Treads", player.kinetic_treads_level)
	add_build_entry(entries, "Ammo Synth", player.ammo_synthesizer_level)
	add_build_entry(entries, "Shatter Rounds", player.shatter_rounds_level)
	add_build_entry(entries, "Phase Core", player.phase_core_level)
	add_build_entry(entries, "Capacitor Bank", player.capacitor_bank_level)
	add_build_entry(entries, "Salvage Magnet", player.salvage_magnet_level)
	add_build_entry(entries, "Emergency Repairs", player.emergency_repairs_level)
	add_build_entry(entries, "Combustion Mix", player.combustion_mix_level)
	add_build_entry(entries, "Heat Sinks", player.heat_sinks_level)
	add_build_entry(entries, "Overclocked Barrel", player.overclocked_barrel_level)
	add_build_entry(entries, "Rail Stabilizer", player.rail_stabilizer_level)
	add_build_entry(entries, "Missile Guidance", player.missile_guidance_level)
	add_build_entry(entries, "Ordnance Bay", player.ordnance_bay_level)
	add_build_entry(entries, "Field Amplifier", player.field_amplifier_level)
	add_build_entry(entries, "Volt Coils", player.volt_coils_level)
	add_build_entry(entries, "Gravity Anchor", player.gravity_anchor_level)
	add_build_entry(entries, "Repair Drones", player.repair_drones_level)
	add_build_entry(entries, "Crystal Lens", player.crystal_lens_level)
	add_build_entry(entries, "Munition Printer", player.munition_printer_level)
	add_build_entry(entries, "Stabilized Chassis", player.stabilized_chassis_level)
	add_build_entry(entries, "Vector Thrusters", player.vector_thrusters_level)
	add_build_entry(entries, "Impact Fuse", player.impact_fuse_level)
	add_build_entry(entries, "Armor Piercers", player.armor_piercers_level)
	add_build_entry(entries, "Weakpoint Scanner", player.weakpoint_scanner_level)
	add_build_entry(entries, "Med Pump", player.med_pump_level)
	add_build_entry(entries, "Orbit Gears", player.orbit_gears_level)
	add_build_entry(entries, "Mine Dispenser", player.mine_dispenser_level)
	add_build_entry(entries, "Drone Command", player.drone_command_level)
	add_build_entry(entries, "Lucky Core", player.lucky_core_level)
	add_build_entry(entries, "Piercing", player.piercing_level)
	add_build_entry(entries, "Splash", player.splash_level)
	add_build_entry(entries, "Magnet", player.magnet_level)
	add_build_entry(entries, "Regen", player.regeneration_level)
	add_build_entry(entries, "EXP", player.exp_bonus_level)
	add_build_entry(entries, "Barbed Wire", player.barbed_wire_level)
	add_build_entry(entries, "Landmine", player.landmine_level)
	add_build_entry(entries, "Circular Saw", player.circular_saw_level)
	add_build_entry(entries, "Footsoldier", player.footsoldier_level)
	add_build_entry(entries, "Shock Field", player.shock_field_level)
	add_build_entry(entries, "Artillery", player.artillery_level)
	add_build_entry(entries, "Drone Swarm", player.drone_swarm_level)
	add_build_entry(entries, "Oil Slick", player.oil_slick_level)
	add_build_entry(entries, "Freeze Pulse", player.freeze_pulse_level)
	add_build_entry(entries, "Chain Lightning", player.chain_lightning_level)
	add_build_entry(entries, "Guardian Satellite", player.guardian_satellite_level)
	add_build_entry(entries, "Overdrive Core", player.overdrive_core_level)
	add_build_entry(entries, "Flame Wave", player.flame_wave_level)
	add_build_entry(entries, "Repair Beacon", player.repair_beacon_level)
	add_build_entry(entries, "Missile Pod", player.missile_pod_level)
	add_build_entry(entries, "Gravity Well", player.gravity_well_level)
	add_build_entry(entries, "Railgun Orbiter", player.railgun_orbiter_level)
	add_build_entry(entries, "Tesla Pylon", player.tesla_pylon_level)
	add_build_entry(entries, "Nanite Cloud", player.nanite_cloud_level)
	add_build_entry(entries, "Ricochet Rounds", player.ricochet_rounds_level)
	add_build_entry(entries, "Chrono Burst", player.chrono_burst_level)
	return get_entries_sorted_by_level(entries)


func add_build_entry(entries: Array[Dictionary], entry_name: String, level: int) -> void:
	if level > 0:
		entries.append({"name": entry_name, "level": level})


func get_entries_sorted_by_level(entries: Array[Dictionary]) -> Array[Dictionary]:
	var sorted_entries: Array[Dictionary] = entries.duplicate(true)
	for i in range(sorted_entries.size()):
		var best_index := i
		for j in range(i + 1, sorted_entries.size()):
			if int(sorted_entries[j].level) > int(sorted_entries[best_index].level):
				best_index = j
		if best_index != i:
			var temp := sorted_entries[i]
			sorted_entries[i] = sorted_entries[best_index]
			sorted_entries[best_index] = temp
	return sorted_entries


func update_upgrade_inventory_label() -> void:
	if player == null:
		return
	
	var rows: Array[String] = [
		"Upgrades",
		format_upgrade_inventory_row("Speed", player.speed_level),
		format_upgrade_inventory_row("Fire Rate", player.fire_rate_level),
		format_upgrade_inventory_row("Damage", player.damage_level),
		format_upgrade_inventory_row("Regen", player.regeneration_level),
		format_upgrade_inventory_row("EXP", player.exp_bonus_level),
		format_upgrade_inventory_row("Splash", player.splash_level),
		format_upgrade_inventory_row("Piercing", player.piercing_level),
		format_upgrade_inventory_row("Barbed Wire", player.barbed_wire_level),
		format_upgrade_inventory_row("Armor", player.armor_level),
		format_upgrade_inventory_row("Magnet", player.magnet_level),
		format_upgrade_inventory_row("Cannon", player.cannon_level),
		format_upgrade_inventory_row("Targeting Array", player.targeting_array_level),
		format_upgrade_inventory_row("Accelerator", player.accelerator_level),
		format_upgrade_inventory_row("Alloy Plating", player.alloy_plating_level),
		format_upgrade_inventory_row("Recycler", player.recycler_level),
		format_upgrade_inventory_row("Payload Rack", player.payload_rack_level),
		format_upgrade_inventory_row("Reactive Shield", player.reactive_shield_level),
		format_upgrade_inventory_row("Gyro Stabilizer", player.gyro_stabilizer_level),
		format_upgrade_inventory_row("Rapid Loader", player.rapid_loader_level),
		format_upgrade_inventory_row("High Caliber", player.high_caliber_level),
		format_upgrade_inventory_row("Nanobots", player.nanobots_level),
		format_upgrade_inventory_row("Kinetic Treads", player.kinetic_treads_level),
		format_upgrade_inventory_row("Ammo Synth", player.ammo_synthesizer_level),
		format_upgrade_inventory_row("Shatter Rounds", player.shatter_rounds_level),
		format_upgrade_inventory_row("Phase Core", player.phase_core_level),
		format_upgrade_inventory_row("Capacitor Bank", player.capacitor_bank_level),
		format_upgrade_inventory_row("Salvage Magnet", player.salvage_magnet_level),
		format_upgrade_inventory_row("Emergency Repairs", player.emergency_repairs_level),
		format_upgrade_inventory_row("Combustion Mix", player.combustion_mix_level),
		format_upgrade_inventory_row("Heat Sinks", player.heat_sinks_level),
		format_upgrade_inventory_row("Overclock Barrel", player.overclocked_barrel_level),
		format_upgrade_inventory_row("Rail Stabilizer", player.rail_stabilizer_level),
		format_upgrade_inventory_row("Missile Guidance", player.missile_guidance_level),
		format_upgrade_inventory_row("Ordnance Bay", player.ordnance_bay_level),
		format_upgrade_inventory_row("Field Amplifier", player.field_amplifier_level),
		format_upgrade_inventory_row("Volt Coils", player.volt_coils_level),
		format_upgrade_inventory_row("Gravity Anchor", player.gravity_anchor_level),
		format_upgrade_inventory_row("Repair Drones", player.repair_drones_level),
		format_upgrade_inventory_row("Crystal Lens", player.crystal_lens_level),
		format_upgrade_inventory_row("Munition Print", player.munition_printer_level),
		format_upgrade_inventory_row("Stabilized Chassis", player.stabilized_chassis_level),
		format_upgrade_inventory_row("Vector Thrusters", player.vector_thrusters_level),
		format_upgrade_inventory_row("Impact Fuse", player.impact_fuse_level),
		format_upgrade_inventory_row("Armor Piercers", player.armor_piercers_level),
		format_upgrade_inventory_row("Weakpoint Scan", player.weakpoint_scanner_level),
		format_upgrade_inventory_row("Med Pump", player.med_pump_level),
		format_upgrade_inventory_row("Orbit Gears", player.orbit_gears_level),
		format_upgrade_inventory_row("Mine Dispenser", player.mine_dispenser_level),
		format_upgrade_inventory_row("Drone Command", player.drone_command_level),
		format_upgrade_inventory_row("Lucky Core", player.lucky_core_level),
		"",
		"Abilities",
		format_upgrade_inventory_row("Landmine", player.landmine_level),
		format_upgrade_inventory_row("Circular Saw", player.circular_saw_level),
		format_upgrade_inventory_row("Footsoldier", player.footsoldier_level),
		format_upgrade_inventory_row("Shock Field", player.shock_field_level),
		format_upgrade_inventory_row("Artillery", player.artillery_level),
		format_upgrade_inventory_row("Drone Swarm", player.drone_swarm_level),
		format_upgrade_inventory_row("Oil Slick", player.oil_slick_level),
		format_upgrade_inventory_row("Freeze Pulse", player.freeze_pulse_level),
		format_upgrade_inventory_row("Chain Lightning", player.chain_lightning_level),
		format_upgrade_inventory_row("Guardian Satellite", player.guardian_satellite_level),
		format_upgrade_inventory_row("Overdrive Core", player.overdrive_core_level),
		format_upgrade_inventory_row("Flame Wave", player.flame_wave_level),
		format_upgrade_inventory_row("Repair Beacon", player.repair_beacon_level),
		format_upgrade_inventory_row("Missile Pod", player.missile_pod_level),
		format_upgrade_inventory_row("Gravity Well", player.gravity_well_level),
		format_upgrade_inventory_row("Railgun Orbiter", player.railgun_orbiter_level),
		format_upgrade_inventory_row("Tesla Pylon", player.tesla_pylon_level),
		format_upgrade_inventory_row("Nanite Cloud", player.nanite_cloud_level),
		format_upgrade_inventory_row("Ricochet Rounds", player.ricochet_rounds_level),
		format_upgrade_inventory_row("Chrono Burst", player.chrono_burst_level),
	]
	if player.has_method("get_active_evolution_names"):
		var evolution_names: Array[String] = player.get_active_evolution_names()
		if not evolution_names.is_empty():
			rows.append("")
			rows.append("Evolutions")
			for evolution_name in evolution_names:
				rows.append(String(evolution_name))
	upgrade_inventory_label.text = "\n".join(rows)


func format_upgrade_inventory_row(label: String, quantity: int) -> String:
	return "%-14s %2d" % [label, quantity]


func update_run_timer_label() -> void:
	run_timer_label.text = get_formatted_run_time()


func get_formatted_run_time() -> String:
	var total_seconds: int = int(floor(run_time))
	return get_formatted_seconds(float(total_seconds))


func get_formatted_seconds(duration_seconds: float) -> String:
	var total_seconds: int = int(floor(duration_seconds))
	var minutes: int = int(float(total_seconds) / 60.0)
	var seconds_remainder: int = total_seconds % 60
	return "%02d:%02d" % [minutes, seconds_remainder]


func _on_restart_button_pressed() -> void:
	if visible:
		Engine.time_scale = 1.0
		get_tree().paused = false
		get_tree().reload_current_scene()


func _on_pause_input_requested() -> void:
	_on_pause_button_pressed()


func _on_restart_input_requested() -> void:
	if %DefeatControl.visible:
		_on_restart_button_pressed()


func _on_pause_button_pressed() -> void:
	if %DefeatControl.visible or player.upgrade_selection_active or player.ability_selection_active:
		return
	
	is_player_paused = not is_player_paused
	get_tree().paused = is_player_paused
	pause_overlay.visible = is_player_paused
	pause_button.text = "RESUME" if is_player_paused else "PAUSE"


func _on_debug_dynamite_button_pressed() -> void:
	debug_spawn_dynamite()


func _on_debug_boss_button_pressed() -> void:
	try_spawn_boss()


func _on_debug_green_supply_button_pressed() -> void:
	debug_spawn_supply_box(SUPPLY_BOX_GREEN, Vector2(96.0, 64.0))


func _on_debug_blue_supply_button_pressed() -> void:
	debug_spawn_supply_box(SUPPLY_BOX_BLUE, Vector2(96.0, -64.0))


func _on_debug_time_scale_button_pressed() -> void:
	set_debug_time_scale_index((debug_time_scale_index + 1) % DEBUG_TIME_SCALES.size())


func set_debug_time_scale_index(index: int) -> void:
	debug_time_scale_index = clampi(index, 0, DEBUG_TIME_SCALES.size() - 1)
	Engine.time_scale = DEBUG_TIME_SCALES[debug_time_scale_index]
	if debug_time_scale_button != null:
		debug_time_scale_button.text = "SPEED: %sx" % int(Engine.time_scale)


func _on_debug_all_ai_button_pressed() -> void:
	var active: bool = not are_all_ai_toggles_active()
	set_all_ai_toggles_active(active)


func cancel_ai_on_manual_movement_input() -> void:
	if not is_any_ai_toggle_active():
		return
	
	for action in MOVEMENT_INPUT_ACTIONS:
		if Input.is_action_pressed(action):
			set_all_ai_toggles_active(false)
			return


func _on_debug_auto_move_button_pressed() -> void:
	var active: bool = not player.is_auto_driver_active()
	player.set_auto_driver_active(active)
	update_ai_debug_button_text()


func _on_debug_enemy_avoidance_button_pressed() -> void:
	var active: bool = not player.is_auto_driver_enemy_avoidance_active()
	player.set_auto_driver_enemy_avoidance_active(active)
	update_ai_debug_button_text()


func _on_debug_exp_seek_button_pressed() -> void:
	var active: bool = not player.is_auto_driver_exp_seek_active()
	player.set_auto_driver_exp_seek_active(active)
	update_ai_debug_button_text()


func _on_debug_wrench_seek_button_pressed() -> void:
	var active: bool = not player.is_auto_driver_wrench_seek_active()
	player.set_auto_driver_wrench_seek_active(active)
	update_ai_debug_button_text()


func _on_debug_powerup_seek_button_pressed() -> void:
	var active: bool = not player.is_auto_driver_powerup_seek_active()
	player.set_auto_driver_powerup_seek_active(active)
	update_ai_debug_button_text()


func _on_debug_supply_seek_button_pressed() -> void:
	var active: bool = not player.is_auto_driver_supply_seek_active()
	player.set_auto_driver_supply_seek_active(active)
	update_ai_debug_button_text()


func _on_debug_upgrade_pick_button_pressed() -> void:
	var active: bool = not player.is_auto_driver_upgrade_pick_active()
	player.set_auto_driver_upgrade_pick_active(active)
	apply_auto_upgrade_pick_to_visible_menu()
	update_ai_debug_button_text()


func set_all_ai_toggles_active(active: bool) -> void:
	player.set_auto_driver_active(active)
	player.set_auto_driver_enemy_avoidance_active(active)
	player.set_auto_driver_exp_seek_active(active)
	player.set_auto_driver_wrench_seek_active(active)
	player.set_auto_driver_powerup_seek_active(active)
	player.set_auto_driver_supply_seek_active(active)
	player.set_auto_driver_upgrade_pick_active(active)
	if active:
		apply_auto_upgrade_pick_to_visible_menu()
	update_ai_debug_button_text()


func are_all_ai_toggles_active() -> bool:
	return (
		player.is_auto_driver_active()
		and player.is_auto_driver_enemy_avoidance_active()
		and player.is_auto_driver_exp_seek_active()
		and player.is_auto_driver_wrench_seek_active()
		and player.is_auto_driver_powerup_seek_active()
		and player.is_auto_driver_supply_seek_active()
		and player.is_auto_driver_upgrade_pick_active()
	)


func is_any_ai_toggle_active() -> bool:
	return (
		player.is_auto_driver_active()
		or player.is_auto_driver_enemy_avoidance_active()
		or player.is_auto_driver_exp_seek_active()
		or player.is_auto_driver_wrench_seek_active()
		or player.is_auto_driver_powerup_seek_active()
		or player.is_auto_driver_supply_seek_active()
		or player.is_auto_driver_upgrade_pick_active()
	)


func update_ai_debug_button_text() -> void:
	debug_all_ai_button.text = "ALL AI: ON" if are_all_ai_toggles_active() else "ALL AI: OFF"
	debug_auto_move_button.text = "AI MOVE: ON" if player.is_auto_driver_active() else "AI MOVE: OFF"
	debug_enemy_avoidance_button.text = "AI AVOID: ON" if player.is_auto_driver_enemy_avoidance_active() else "AI AVOID: OFF"
	debug_exp_seek_button.text = "AI EXP: ON" if player.is_auto_driver_exp_seek_active() else "AI EXP: OFF"
	debug_wrench_seek_button.text = "AI WRENCH: ON" if player.is_auto_driver_wrench_seek_active() else "AI WRENCH: OFF"
	debug_powerup_seek_button.text = "AI POWER: ON" if player.is_auto_driver_powerup_seek_active() else "AI POWER: OFF"
	debug_supply_seek_button.text = "AI BOX: ON" if player.is_auto_driver_supply_seek_active() else "AI BOX: OFF"
	debug_upgrade_pick_button.text = "AI PICK: ON" if player.is_auto_driver_upgrade_pick_active() else "AI PICK: OFF"


func apply_auto_upgrade_pick_to_visible_menu() -> void:
	if not player.is_auto_driver_upgrade_pick_active():
		return
	
	for child in get_children():
		if child.has_method("pick_random_upgrade"):
			child.call_deferred("pick_random_upgrade")
		if child.has_method("pick_random_ability"):
			child.call_deferred("pick_random_ability")
