extends Node2D

var player: CharacterBody2D

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
var is_player_paused: bool = false
var enemies_defeated: int = 0
var bosses_defeated: int = 0
var elites_defeated: int = 0
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
	{"id": "scout", "scene": ENEMY, "unlock_seconds": 0.0, "base_weight": 100.0, "growth_per_minute": -5.0, "min_weight": 5.0, "max_weight": 100.0, "health": 12, "speed": 58.0, "contact_damage": 1, "exp_drop_count": 1, "exp_drop_min_tier": 1, "color": Color(1.0, 0.08, 0.04, 1.0), "scale": 0.82, "movement_style": "chase"},
	{"id": "bruiser", "scene": BROWN_ENEMY, "unlock_seconds": 120.0, "base_weight": 22.0, "growth_per_minute": 2.5, "min_weight": 0.0, "max_weight": 45.0, "health": 22, "speed": 46.0, "contact_damage": 2, "exp_drop_count": 2, "exp_drop_min_tier": 1, "color": Color(0.5, 0.22, 0.08, 1.0), "scale": 1.08, "movement_style": "chase"},
	{"id": "runner", "scene": ENEMY, "unlock_seconds": 180.0, "base_weight": 18.0, "growth_per_minute": 2.0, "min_weight": 0.0, "max_weight": 38.0, "health": 10, "speed": 94.0, "contact_damage": 1, "exp_drop_count": 1, "exp_drop_min_tier": 1, "color": Color(1.0, 0.66, 0.05, 1.0), "scale": 0.72, "movement_style": "sprinter"},
	{"id": "shield", "scene": SHIELDED_ENEMY, "unlock_seconds": 240.0, "base_weight": 14.0, "growth_per_minute": 2.0, "min_weight": 0.0, "max_weight": 35.0, "health": 48, "speed": 27.0, "contact_damage": 3, "exp_drop_count": 3, "exp_drop_min_tier": 2, "color": Color(0.7, 0.72, 0.66, 1.0), "scale": 1.0, "movement_style": "chase"},
	{"id": "zigzag", "scene": ENEMY, "unlock_seconds": 300.0, "base_weight": 16.0, "growth_per_minute": 1.5, "min_weight": 0.0, "max_weight": 30.0, "health": 20, "speed": 68.0, "contact_damage": 2, "exp_drop_count": 2, "exp_drop_min_tier": 1, "color": Color(0.15, 0.8, 1.0, 1.0), "scale": 0.9, "movement_style": "zigzag"},
	{"id": "swarm", "scene": ENEMY, "unlock_seconds": 360.0, "base_weight": 24.0, "growth_per_minute": 2.0, "min_weight": 0.0, "max_weight": 42.0, "health": 8, "speed": 76.0, "contact_damage": 1, "exp_drop_count": 1, "exp_drop_min_tier": 1, "color": Color(1.0, 0.18, 0.38, 1.0), "scale": 0.58, "movement_style": "weaver"},
	{"id": "stalker", "scene": ENEMY, "unlock_seconds": 480.0, "base_weight": 16.0, "growth_per_minute": 2.0, "min_weight": 0.0, "max_weight": 35.0, "health": 34, "speed": 54.0, "contact_damage": 3, "exp_drop_count": 3, "exp_drop_min_tier": 2, "color": Color(0.55, 0.1, 0.9, 1.0), "scale": 0.96, "movement_style": "stalker"},
	{"id": "orbiter", "scene": ENEMY, "unlock_seconds": 600.0, "base_weight": 15.0, "growth_per_minute": 1.8, "min_weight": 0.0, "max_weight": 32.0, "health": 42, "speed": 62.0, "contact_damage": 3, "exp_drop_count": 3, "exp_drop_min_tier": 2, "color": Color(0.15, 1.0, 0.38, 1.0), "scale": 0.92, "movement_style": "orbiter"},
	{"id": "tank", "scene": SHIELDED_ENEMY, "unlock_seconds": 720.0, "base_weight": 12.0, "growth_per_minute": 1.5, "min_weight": 0.0, "max_weight": 28.0, "health": 86, "speed": 21.0, "contact_damage": 5, "exp_drop_count": 5, "exp_drop_min_tier": 3, "color": Color(0.2, 0.28, 0.3, 1.0), "scale": 1.22, "movement_style": "chase"},
	{"id": "drifter", "scene": ENEMY, "unlock_seconds": 840.0, "base_weight": 18.0, "growth_per_minute": 2.0, "min_weight": 0.0, "max_weight": 36.0, "health": 54, "speed": 70.0, "contact_damage": 4, "exp_drop_count": 4, "exp_drop_min_tier": 3, "color": Color(0.98, 0.92, 0.16, 1.0), "scale": 1.0, "movement_style": "drifter"},
]

var boss_variant_catalog: Array[Dictionary] = [
	{"id": "charger", "scene": BOSS_ENEMY, "unlock_seconds": 0.0, "weight": 100.0, "health": 950, "speed": 25.0, "contact_damage": 5, "exp_drop_count": 30, "exp_drop_min_tier": 1, "color": Color(0.5, 0.05, 0.62, 1.0), "scale": 1.0, "behavior": "charger"},
	{"id": "bulwark", "scene": BOSS_ENEMY, "unlock_seconds": 420.0, "weight": 55.0, "health": 1550, "speed": 17.0, "contact_damage": 8, "exp_drop_count": 38, "exp_drop_min_tier": 2, "color": Color(0.18, 0.45, 0.8, 1.0), "scale": 1.18, "behavior": "bulwark", "phase_thresholds": [0.55], "ability_modules": [{"type": "minion_call", "cooldown": 8.0, "initial_delay": 3.5, "count": 3, "phase_count_bonus": 2}]},
	{"id": "sprinter", "scene": BOSS_ENEMY, "unlock_seconds": 840.0, "weight": 45.0, "health": 1100, "speed": 34.0, "contact_damage": 6, "exp_drop_count": 42, "exp_drop_min_tier": 2, "color": Color(1.0, 0.38, 0.08, 1.0), "scale": 0.9, "behavior": "sprinter"},
	{"id": "crusher", "scene": BOSS_ENEMY, "unlock_seconds": 1260.0, "weight": 42.0, "health": 2200, "speed": 15.0, "contact_damage": 11, "exp_drop_count": 52, "exp_drop_min_tier": 3, "color": Color(0.7, 0.08, 0.08, 1.0), "scale": 1.35, "behavior": "crusher", "phase_thresholds": [0.65, 0.32], "ability_modules": [{"type": "hazard_ring", "cooldown": 7.2, "initial_delay": 2.8, "count": 5, "phase_count_bonus": 2, "radius": 74.0, "ring_distance": 170.0, "damage": 3}]},
	{"id": "wraith", "scene": BOSS_ENEMY, "unlock_seconds": 1680.0, "weight": 40.0, "health": 1750, "speed": 30.0, "contact_damage": 9, "exp_drop_count": 60, "exp_drop_min_tier": 4, "color": Color(0.72, 0.2, 1.0, 1.0), "scale": 1.02, "behavior": "wraith", "phase_thresholds": [0.5], "ability_modules": [{"type": "target_hazard", "cooldown": 5.6, "initial_delay": 2.2, "radius": 64.0, "damage": 3}, {"type": "minion_call", "cooldown": 11.0, "initial_delay": 5.0, "count": 2, "phase_count_bonus": 1}]},
]

var enemy_affix_catalog: Array[Dictionary] = [
	{"id": "hasty", "name": "Hasty", "unlock_seconds": 90.0, "weight": 28.0, "speed_multiplier": 1.45, "health_multiplier": 0.85, "color": Color(1.0, 0.95, 0.16, 1.0)},
	{"id": "armored", "name": "Armored", "unlock_seconds": 150.0, "weight": 24.0, "speed_multiplier": 0.82, "health_multiplier": 1.85, "scale_multiplier": 1.12, "color": Color(0.62, 0.72, 0.84, 1.0)},
	{"id": "rich", "name": "Rich", "unlock_seconds": 210.0, "weight": 18.0, "health_multiplier": 1.2, "exp_drop_multiplier": 2.4, "exp_drop_min_tier_bonus": 1, "color": Color(0.46, 1.0, 0.35, 1.0)},
	{"id": "volatile", "name": "Volatile", "unlock_seconds": 300.0, "weight": 16.0, "speed_multiplier": 1.18, "health_multiplier": 0.9, "death_effect": "volatile", "death_radius": 92.0, "death_damage": 34.0, "color": Color(1.0, 0.18, 0.08, 1.0)},
	{"id": "splitting", "name": "Splitting", "unlock_seconds": 420.0, "weight": 14.0, "health_multiplier": 1.35, "death_effect": "split", "split_count": 2, "split_health": 8, "split_speed": 82.0, "color": Color(0.95, 0.36, 1.0, 1.0)},
]

const MAGNET_DURATION: float = 5.0
const MAGNET_SPAWN_INTERVAL: float = 180.0
const SUPPLY_BOX_SPAWN_INTERVAL: float = 15.0
const SUPPLY_BOX_SPAWN_CHANCE: float = 0.05
const BLUE_SUPPLY_BOX_CHANCE: float = 0.2
const BOSS_SPAWN_INTERVAL: float = 420.0
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
const MAX_ACTIVE_PARTICLE_BURSTS: int = 36
const MAX_ACTIVE_SPLASH_AREAS: int = 24
const MAX_ACTIVE_BOSS_HAZARDS: int = 18
const MASS_SPLASH_ENEMY_THRESHOLD: int = 12
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

@onready var arena_mesh: MeshInstance2D = $ArenaMesh
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
	configure_run_seed_and_modifiers()
	set_debug_time_scale_index(0)
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
	player.defeated.connect(func():
		set_all_ai_toggles_active(false)
		low_health_vignette.set_low_health_active(false)
		get_tree().paused = true
		%DefeatControl.visible = true
		var unlocked_messages: Array[String] = get_unlock_manager().record_run_result({
			"survival_seconds": int(floor(run_time)),
			"level": player.level,
			"enemies_defeated": enemies_defeated,
			"bosses_defeated": bosses_defeated,
		})
		var unlock_text := ""
		if not unlocked_messages.is_empty():
			unlock_text = "\nUnlocked: %s" % ", ".join(unlocked_messages)
		%ResultLabel.text = get_run_summary_text(unlock_text)
	)


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
	wrench_drop_chance = clamp(WRENCH_DROP_CHANCE * float(run_config.get_modifier_multiplier("wrench_drop_multiplier")), 0.0, 1.0)
	dynamite_drop_chance = clamp(DYNAMITE_DROP_CHANCE * float(run_config.get_modifier_multiplier("dynamite_drop_multiplier")), 0.0, 1.0)
	spawn_interval *= float(run_config.get_modifier_multiplier("spawn_interval_multiplier"))


func get_run_config() -> Node:
	return get_node("/root/RunConfig")


func get_unlock_manager() -> Node:
	return get_node("/root/UnlockManager")


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
	cancel_ai_on_manual_movement_input()
	low_health_vignette.set_low_health_active(player.health > 0 and player.get_health_ratio() <= 0.4)
	dynamite_flash.color.a = move_toward(dynamite_flash.color.a, 0.0, 7.0 * delta)
	update_stats_label()
	process_queued_exp_drops()
	update_visibility_culling()
	run_time += delta
	update_player_dps()
	update_low_health_upgrade_timer(delta)
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
		
		for enemy in get_tree().get_nodes_in_group("Enemy"):
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
	
	if spawn_timer >= spawn_interval:
		var enemy_config := get_enemy_config_to_spawn()
		enemy_config = apply_random_elite_affix(enemy_config)
		spawn_enemy(enemy_config.scene, _on_enemy_defeated, enemy_config)
		spawn_timer = 0.0


func run_startup_loading() -> void:
	await get_tree().process_frame
	await warmup_runtime_scenes()
	await fade_loading_overlay()
	loading_overlay.visible = false
	is_startup_loading = false
	if not is_player_paused and not %DefeatControl.visible:
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


func spawn_enemy(enemy_scene: PackedScene, defeated_callback: Callable, variant_config: Dictionary = {}) -> Node:
	var enemy = enemy_scene.instantiate()
	if not variant_config.is_empty() and enemy.has_method("configure_variant"):
		enemy.configure_variant(variant_config)
	enemy.defeated.connect(defeated_callback)
	add_child(enemy)
	enemy.global_position = get_boss_spawn_point() if enemy.is_in_group("Boss") else get_spawn_point()
	if enemy.has_method("set_global_speed_scale"):
		enemy.set_global_speed_scale(enemy_speed_scale)
	if enemy.has_method("apply_health_bonus"):
		enemy.apply_health_bonus(enemy_health_bonus_total)
	return enemy


func spawn_projectile(config: Dictionary, spawn_position: Vector2) -> Node:
	var projectile := acquire_projectile()
	projectile.launch(config)
	projectile.global_position = spawn_position
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
	if projectile_pool.size() >= PROJECTILE_POOL_LIMIT:
		projectile.queue_free()
		return
	if projectile.get_parent() != self:
		projectile.reparent(self)
	projectile_pool.append(projectile)


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
	
	return displayed_upgrades.pick_random()


func try_spawn_boss() -> void:
	if is_boss_alive():
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
	if get_active_enemy_count() >= ELITE_SPLIT_ACTIVE_ENEMY_CAP:
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
		if get_active_enemy_count() >= ELITE_SPLIT_ACTIVE_ENEMY_CAP:
			return
		var minion = spawn_enemy(ENEMY, _on_enemy_defeated, minion_config)
		minion.global_position = origin + Vector2.RIGHT.rotated((TAU / float(spawn_count)) * float(i)) * randf_range(80.0, 128.0)


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


func spawn_boss_hazard(hazard_position: Vector2, radius: float, damage: int) -> void:
	if get_tree().get_nodes_in_group("BossHazard").size() >= MAX_ACTIVE_BOSS_HAZARDS:
		return
	var hazard = BOSS_HAZARD.instantiate()
	add_child(hazard)
	hazard.add_to_group("BossHazard")
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
	for boss in get_tree().get_nodes_in_group("Boss"):
		if is_instance_valid(boss):
			return true
	
	return false


func apply_enemy_health_bonus_to_active_enemies() -> void:
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		if is_instance_valid(enemy) and enemy.has_method("apply_health_bonus"):
			enemy.apply_health_bonus(enemy_health_bonus_total)


func get_scaled_enemy_contact_damage(base_damage: int) -> int:
	return maxi(1, int(round(float(base_damage) * enemy_damage_multiplier)))


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


func get_arena_rect() -> Rect2:
	var arena_size: Vector2 = arena_mesh.mesh.size
	return Rect2(arena_mesh.global_position - arena_size / 2.0, arena_size)


func get_camera_viewport_rect() -> Rect2:
	var screen_size := get_viewport_rect().size
	return Rect2(player.global_position - screen_size / 2.0, screen_size)


func update_visibility_culling() -> void:
	var visible_rect := get_camera_viewport_rect().grow(VISIBILITY_CULL_MARGIN)
	for group_name in VISIBILITY_CULL_GROUPS:
		for node in get_tree().get_nodes_in_group(group_name):
			if node is CanvasItem and is_instance_valid(node):
				node.visible = visible_rect.has_point(node.global_position)


func get_enemy_config_to_spawn() -> Dictionary:
	return pick_weighted_entry(get_unlocked_weighted_entries(enemy_variant_catalog))


func get_boss_config_to_spawn() -> Dictionary:
	return pick_weighted_entry(get_unlocked_weighted_entries(boss_variant_catalog))


func apply_random_elite_affix(enemy_config: Dictionary) -> Dictionary:
	var elite_chance := get_elite_spawn_chance()
	if randf() > elite_chance:
		return enemy_config
	
	var affix := get_affix_config_to_apply()
	if affix.is_empty():
		return enemy_config
	
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
	return lerpf(0.02, ELITE_CHANCE_MAX, progress)


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
		var unlock_seconds := float(config.get("unlock_seconds", 0.0))
		if run_time < unlock_seconds:
			continue
		
		var minutes_since_unlock: float = max((run_time - unlock_seconds) / 60.0, 0.0)
		var weight: float = float(config.get("weight", config.get("base_weight", 0.0)))
		weight += minutes_since_unlock * float(config.get("growth_per_minute", 0.0))
		weight = clamp(weight, float(config.get("min_weight", 0.0)), float(config.get("max_weight", weight)))
		if weight <= 0.0:
			continue
		
		entries.append({"config": config, "weight": weight})
	
	return entries


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


func apply_elite_death_payload(enemy_position: Vector2, death_payload: Dictionary) -> void:
	if death_payload.is_empty():
		return
	
	match String(death_payload.get("effect", "")):
		"volatile":
			apply_volatile_elite_death(enemy_position, float(death_payload.get("radius", 90.0)), float(death_payload.get("damage", 30.0)))
		"split":
			spawn_split_elite_children(enemy_position, death_payload)


func apply_volatile_elite_death(enemy_position: Vector2, radius: float, damage: float) -> void:
	splash_blast_active = true
	for enemy in get_tree().get_nodes_in_group("Enemy"):
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
	if get_active_enemy_count() >= ELITE_SPLIT_ACTIVE_ENEMY_CAP:
		return
	
	var child_scene: PackedScene = death_payload.get("scene", ENEMY) as PackedScene
	var child_config: Dictionary = death_payload.get("config", {}) as Dictionary
	for i in range(child_count):
		if get_active_enemy_count() >= ELITE_SPLIT_ACTIVE_ENEMY_CAP:
			return
		var child = spawn_enemy(child_scene, _on_enemy_defeated, child_config)
		child.global_position = enemy_position + Vector2.RIGHT.rotated((TAU / float(child_count)) * float(i) + randf_range(-0.35, 0.35)) * randf_range(14.0, 28.0)


func get_active_enemy_count() -> int:
	return get_tree().get_nodes_in_group("Enemy").size()


func _on_boss_defeated(enemy_position: Vector2, exp_drop_count: int = 30, exp_drop_min_tier: int = BLUE_ORB_TIER) -> void:
	enemies_defeated += 1
	bosses_defeated += 1
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
	
	var enemy_position: Vector2 = drop_data.position
	var min_tier: int = drop_data.get("min_tier", BLUE_ORB_TIER)
	var orb_data := get_random_exp_orb_data(min_tier)
	if get_tree().get_nodes_in_group("ExpOrb").size() >= MAX_ACTIVE_EXP_ORBS:
		merge_exp_into_existing_orb(orb_data.value)
		return
	
	var exp_orb = EXP_ORB.instantiate()
	add_child(exp_orb)
	exp_orb.global_position = enemy_position
	exp_orb.configure(int(ceil(float(orb_data.value) * exp_value_multiplier)), orb_data.radius, orb_data.texture, orb_data.get("visual_scale", 1.0))
	
	if magnet_effect_timer > 0.0:
		exp_orb.set_magnet_active(true, player)


func get_random_exp_orb_data(min_tier: int = BLUE_ORB_TIER) -> Dictionary:
	if min_tier >= VIOLET_ORB_TIER:
		return get_violet_exp_orb_data()
	
	if min_tier >= ORANGE_ORB_TIER:
		var advanced_total: float = violet_orb_drop_chance + purple_orb_drop_chance + orange_orb_drop_chance
		if advanced_total <= 0.0:
			return {"value": 4, "radius": 7.0, "texture": BLUE_EXP_CRYSTAL, "visual_scale": 0.5}
		
		var advanced_roll := randf() * advanced_total
		if advanced_roll < violet_orb_drop_chance:
			return get_violet_exp_orb_data()
		if advanced_roll < violet_orb_drop_chance + purple_orb_drop_chance:
			return {"value": 9, "radius": 10.0, "texture": RED_EXP_CRYSTAL, "visual_scale": 0.36}
		
		return {"value": 4, "radius": 7.0, "texture": BLUE_EXP_CRYSTAL, "visual_scale": 0.5}
	
	var orb_roll := randf()
	if orb_roll < violet_orb_drop_chance:
		return get_violet_exp_orb_data()
	elif orb_roll < violet_orb_drop_chance + purple_orb_drop_chance:
		return {"value": 9, "radius": 10.0, "texture": RED_EXP_CRYSTAL, "visual_scale": 0.36}
	elif orb_roll < violet_orb_drop_chance + purple_orb_drop_chance + orange_orb_drop_chance:
		return {"value": 4, "radius": 7.0, "texture": BLUE_EXP_CRYSTAL, "visual_scale": 0.5}
	
	return {"value": 2, "radius": 5.0, "texture": GREEN_EXP_CRYSTAL}


func get_violet_exp_orb_data() -> Dictionary:
	return {"value": 18, "radius": 12.0, "texture": PURPLE_EXP_CRYSTAL, "visual_scale": 0.5}


func merge_exp_into_existing_orb(additional_value: int) -> void:
	var exp_orbs := get_tree().get_nodes_in_group("ExpOrb")
	if exp_orbs.is_empty():
		return
	
	var target_orb = exp_orbs.pick_random()
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
	
	dynamite_pickup_pool.activate(enemy_position)


func try_drop_wrench(enemy_position: Vector2) -> void:
	if randf() > wrench_drop_chance:
		return
	
	if not is_position_in_arena(enemy_position):
		return
	
	var wrench_pickup := get_available_wrench_pickup()
	if wrench_pickup == null:
		return
	
	wrench_pickup.activate(enemy_position)


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
	dynamite_pickup_pool.activate(spawn_position)


func spawn_enemy_death_burst(enemy_position: Vector2) -> void:
	spawn_particle_burst(self, enemy_position, 10, Color(1, 0.08, 0.02, 1), 200.0, 0.3, Vector2(12.0, 16.0), true)


func spawn_boss_death_burst(enemy_position: Vector2) -> void:
	spawn_particle_burst(self, enemy_position, 80, Color(1.0, 0.22, 0.04, 1), 300.0, 0.6, Vector2(24.0, 36.0), true)


func _on_player_damaged(player_position: Vector2) -> void:
	spawn_particle_burst(self, player_position, 50, Color(1, 0, 0, 1), 200.0, 0.5, Vector2(2.0, 3.0), false)


func spawn_exp_pickup_burst() -> void:
	var burst_position: Vector2 = exp_bar.get_fill_end_global_position()
	spawn_particle_burst($CanvasLayer, burst_position, 15, Color(1, 0.9, 0.05, 1), 200.0, 0.3, Vector2(2.0, 3.0), false)


func spawn_particle_burst(parent: Node, burst_position: Vector2, count: int, color: Color, speed: float, duration: float, size_range: Vector2, shrink: bool) -> void:
	if get_tree().get_nodes_in_group("ParticleBurst").size() >= MAX_ACTIVE_PARTICLE_BURSTS:
		return
	var burst = acquire_particle_burst(parent)
	burst.add_to_group("ParticleBurst")
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


func _spawn_splash_area(splash_position: Vector2, splash_radius: float, damage: float, enemies: Array[Area2D]) -> void:
	if get_tree().get_nodes_in_group("SplashArea").size() >= MAX_ACTIVE_SPLASH_AREAS:
		return
	var splash = SPLASH_AREA.instantiate()
	add_child(splash)
	splash.add_to_group("SplashArea")
	splash.global_position = splash_position
	var is_mass_splash := enemies.size() >= MASS_SPLASH_ENEMY_THRESHOLD
	splash_blast_active = is_mass_splash
	splash.configure(splash_radius, damage, enemies, not is_mass_splash)
	splash_blast_active = false


func activate_dynamite() -> void:
	dynamite_flash.color.a = 0.85
	var enemies := get_tree().get_nodes_in_group("Enemy").duplicate()
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
	for exp_orb in get_tree().get_nodes_in_group("ExpOrb"):
		if exp_orb.has_method("set_magnet_active"):
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
	if spawn_position == Vector2.INF:
		return
	
	var supply_box_scene := SUPPLY_BOX_BLUE if randf() < BLUE_SUPPLY_BOX_CHANCE else SUPPLY_BOX_GREEN
	var supply_box = supply_box_scene.instantiate()
	add_child(supply_box)
	supply_box.global_position = spawn_position


func debug_spawn_supply_box(supply_box_scene: PackedScene, offset: Vector2) -> void:
	var spawn_position := player.global_position + offset
	var arena_rect := get_arena_rect()
	spawn_position.x = clamp(spawn_position.x, arena_rect.position.x + 32.0, arena_rect.end.x - 32.0)
	spawn_position.y = clamp(spawn_position.y, arena_rect.position.y + 32.0, arena_rect.end.y - 32.0)
	
	var supply_box = supply_box_scene.instantiate()
	add_child(supply_box)
	supply_box.global_position = spawn_position


func get_offscreen_arena_spawn_point() -> Vector2:
	var arena_rect := get_arena_rect()
	var camera_rect := get_camera_viewport_rect()
	
	for i in range(100):
		var candidate := Vector2(
			randf_range(arena_rect.position.x, arena_rect.end.x),
			randf_range(arena_rect.position.y, arena_rect.end.y)
		)
		
		if not camera_rect.has_point(candidate):
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
	stats_label.text = "Tank: %s\nDamage: %.1f\nDPS: %.1f / %.1f HP\nBarbed Wire: %.0f%% / 0.5s\nSplash Radius: %.0f px\nCannons: %s\nMove Speed: %.0f\nFire Rate: %.3fs\nArmor: %s%%\nRegen: %.3f HP/s\nEXP Mult: %s%%" % [
		player.selected_tank_name,
		player.attack_damage,
		player_dps,
		get_average_spawn_enemy_hp(),
		float(player.barbed_wire_level) * 33.0,
		player.get_splash_radius(),
		1 + player.cannon_level,
		player.speed,
		player.fire_interval,
		armor_percent,
		regen_per_second,
		exp_multiplier_percent
	]


func get_run_summary_text(unlock_text: String) -> String:
	var lines: Array[String] = [
		"Tank: %s  Level: %s" % [player.selected_tank_name, player.level],
		"Time: %s  Seed: %s" % [get_formatted_run_time(), run_seed_text],
		"Modifiers: %s" % run_modifier_summary,
		"Kills: %s  Elites: %s  Bosses: %s" % [enemies_defeated, elites_defeated, bosses_defeated],
		"Damage Dealt: %s  Taken: %s  DPS: %.1f" % [total_damage_dealt, total_damage_taken, player_dps],
		"Build: %s" % get_build_summary_text(),
	]
	if unlock_text != "":
		lines.append(unlock_text.strip_edges())
	return "\n".join(lines)


func get_build_summary_text() -> String:
	var entries := get_ranked_build_entries()
	if entries.is_empty():
		return "No upgrades"
	
	var top_entries: Array[String] = []
	for i in range(mini(4, entries.size())):
		top_entries.append("%s %s" % [String(entries[i].name), int(entries[i].level)])
	return ", ".join(top_entries)


func get_ranked_build_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	add_build_entry(entries, "Damage", player.damage_level)
	add_build_entry(entries, "Fire Rate", player.fire_rate_level)
	add_build_entry(entries, "Speed", player.speed_level)
	add_build_entry(entries, "Armor", player.armor_level)
	add_build_entry(entries, "Cannon", player.cannon_level)
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
	]
	upgrade_inventory_label.text = "\n".join(rows)


func format_upgrade_inventory_row(label: String, quantity: int) -> String:
	return "%-14s %2d" % [label, quantity]


func update_run_timer_label() -> void:
	run_timer_label.text = get_formatted_run_time()


func get_formatted_run_time() -> String:
	var total_seconds: int = int(floor(run_time))
	var minutes: int = int(float(total_seconds) / 60.0)
	var seconds: int = total_seconds % 60
	return "%02d:%02d" % [minutes, seconds]


func _on_restart_button_pressed() -> void:
	if visible:
		Engine.time_scale = 1.0
		get_tree().paused = false
		get_tree().reload_current_scene()


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
