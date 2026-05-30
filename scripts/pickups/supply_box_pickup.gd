extends Area2D

@export var grants_ability: bool = false

var dingle_time: float = 0.0

@onready var pickup_sprite: Sprite2D = $PickupSprite


func _process(delta: float) -> void:
	dingle_time += delta
	var cycle_time := fmod(dingle_time, 1.0)
	if cycle_time < 0.5:
		pickup_sprite.rotation = sin(cycle_time / 0.5 * TAU) * deg_to_rad(8.0)
	else:
		pickup_sprite.rotation = move_toward(pickup_sprite.rotation, 0.0, deg_to_rad(32.0) * delta)


func get_indicator_color() -> Color:
	if grants_ability:
		return Color(0.32, 0.83, 1.0, 1.0)
	
	return Color(0.2, 0.95, 0.25, 1.0)


func get_indicator_outline_color() -> Color:
	if grants_ability:
		return Color(0.78, 0.96, 1.0, 1.0)
	
	return Color(0.78, 1.0, 0.72, 1.0)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return
	
	if grants_ability:
		if body.has_method("request_supply_ability_selection"):
			body.request_supply_ability_selection()
	else:
		if body.has_method("request_supply_upgrade_selection"):
			body.request_supply_upgrade_selection()
	
	queue_free()
