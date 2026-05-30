extends Area2D

const HIT_COOLDOWN: float = 0.35
const SELF_ROTATION_SPEED: float = TAU * 4.0
const ORBIT_RADIUS: float = 100.0

var player: CharacterBody2D
var saw_index: int = 0
var saw_count: int = 1
var hit_cooldowns := {}


func _process(delta: float) -> void:
	if player == null or player.is_dead:
		queue_free()
		return
	
	update_hit_cooldowns(delta)
	var spacing_angle := TAU * float(saw_index) / float(max(saw_count, 1))
	global_position = player.global_position + Vector2.RIGHT.rotated(player.circular_saw_orbit_angle + spacing_angle) * ORBIT_RADIUS
	$PickupSprite.rotation += SELF_ROTATION_SPEED * delta
	apply_contact_damage()


func update_hit_cooldowns(delta: float) -> void:
	for enemy in hit_cooldowns.keys():
		if not is_instance_valid(enemy):
			hit_cooldowns.erase(enemy)
			continue
		
		hit_cooldowns[enemy] -= delta
		if hit_cooldowns[enemy] <= 0.0:
			hit_cooldowns.erase(enemy)


func apply_contact_damage() -> void:
	for area in get_overlapping_areas():
		if not area.is_in_group("Enemy"):
			continue
		if hit_cooldowns.has(area):
			continue
		if area.has_method("is_damageable") and not area.is_damageable():
			continue
		if not area.has_method("hit"):
			continue
		
		hit_cooldowns[area] = HIT_COOLDOWN
		var actual_damage: int = area.hit(ceili(player.attack_damage / 3.0))
		var main := get_tree().current_scene
		if actual_damage > 0 and main and main.has_method("record_player_damage"):
			main.record_player_damage(actual_damage)
