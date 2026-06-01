extends Area2D

const HEAL_AMOUNT: int = 2

var is_active: bool = true
var pulse_time: float = 0.0


func activate(spawn_position: Vector2) -> void:
	global_position = spawn_position
	visible = true
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)
	is_active = true
	if not is_in_group("WrenchPickup"):
		add_to_group("WrenchPickup")


func deactivate() -> void:
	is_active = false
	visible = false
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	global_position = Vector2(-100000.0, -100000.0)
	if is_in_group("WrenchPickup"):
		remove_from_group("WrenchPickup")


func _process(delta: float) -> void:
	if not is_active:
		return
	
	pulse_time += delta
	var pulse: float = 1.0 + sin(pulse_time * TAU * 2.0) * 0.15
	$PickupSprite.scale = Vector2.ONE * 0.48 * pulse
	try_player_radius_pickup()


func try_player_radius_pickup() -> void:
	var player := get_tree().get_first_node_in_group("Player")
	if player == null or not player is Node2D:
		return
	var pickup_radius := 36.0
	if player.has_method("get_pickup_collection_radius"):
		pickup_radius = max(pickup_radius, float(player.get_pickup_collection_radius()))
	if global_position.distance_to((player as Node2D).global_position) <= pickup_radius:
		collect(player as Node2D)


func _on_body_entered(body: Node2D) -> void:
	if not is_active or not body.is_in_group("Player"):
		return
	collect(body)
	

func collect(body: Node2D) -> void:
	if not is_active:
		return
	if not body.has_method("heal"):
		return
	
	var healed_amount: int = body.heal(HEAL_AMOUNT)
	if healed_amount <= 0:
		return
	
	var main := get_tree().current_scene
	if main and main.has_method("show_healing_popup"):
		main.show_healing_popup(body.global_position, healed_amount)
	
	deactivate()
