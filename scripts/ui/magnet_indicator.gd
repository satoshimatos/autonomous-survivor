extends Control

const EDGE_MARGIN: float = 26.0
const MAGNET_ICON_COLOR := Color(0.02, 0.08, 0.45, 1)
const MAGNET_ICON_OUTLINE := Color(0.5, 0.72, 1.0, 1)
const DYNAMITE_ICON_COLOR := Color(1, 0, 0, 1)
const DYNAMITE_ICON_OUTLINE := Color(1, 0.65, 0.65, 1)
const SUPPLY_ICON_COLOR := Color(0.2, 0.95, 0.25, 1)
const SUPPLY_ICON_OUTLINE := Color(0.78, 1.0, 0.72, 1)

var player: Node2D


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("Player") as Node2D
	if player == null:
		return
	
	var screen_size: Vector2 = get_viewport_rect().size
	var center: Vector2 = screen_size / 2.0
	var half_size: Vector2 = center - Vector2(EDGE_MARGIN, EDGE_MARGIN)
	var camera_rect: Rect2 = Rect2(player.global_position - screen_size / 2.0, screen_size)
	
	draw_pickup_indicators("MagnetPickup", MAGNET_ICON_COLOR, MAGNET_ICON_OUTLINE, camera_rect, center, half_size)
	draw_pickup_indicators("DynamitePickup", DYNAMITE_ICON_COLOR, DYNAMITE_ICON_OUTLINE, camera_rect, center, half_size)
	draw_pickup_indicators("SupplyBoxPickup", SUPPLY_ICON_COLOR, SUPPLY_ICON_OUTLINE, camera_rect, center, half_size)


func draw_pickup_indicators(group_name: String, icon_color: Color, outline_color: Color, camera_rect: Rect2, center: Vector2, half_size: Vector2) -> void:
	for pickup in get_tree().get_nodes_in_group(group_name):
		if camera_rect.has_point(pickup.global_position):
			continue
		
		var direction: Vector2 = player.global_position.direction_to(pickup.global_position)
		if direction == Vector2.ZERO:
			continue
		
		var scale_x: float = INF if is_zero_approx(direction.x) else half_size.x / abs(direction.x)
		var scale_y: float = INF if is_zero_approx(direction.y) else half_size.y / abs(direction.y)
		var icon_position: Vector2 = center + direction * min(scale_x, scale_y)
		var side: Vector2 = Vector2(-direction.y, direction.x)
		var current_icon_color := icon_color
		var current_outline_color := outline_color
		if pickup.has_method("get_indicator_color"):
			current_icon_color = pickup.get_indicator_color()
		if pickup.has_method("get_indicator_outline_color"):
			current_outline_color = pickup.get_indicator_outline_color()
		
		var points := PackedVector2Array([
			icon_position + direction * 13.0,
			icon_position - direction * 8.0 + side * 8.0,
			icon_position - direction * 8.0 - side * 8.0,
		])
		
		draw_colored_polygon(points, current_icon_color)
		draw_polyline(PackedVector2Array([points[0], points[1], points[2], points[0]]), current_outline_color, 2.0)
