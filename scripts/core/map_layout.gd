extends Node2D

const MAP1_ID: String = "map1"
const MAP2_ID: String = "map2"
const MAP1_ARENA_SIZE: Vector2 = Vector2(1620, 930)
const MAP1_BOUNDS_SIZE: Vector2 = Vector2(1940, 1250)
const MAP2_ARENA_SIZE: Vector2 = Vector2(2300, 1400)
const MAP2_BOUNDS_SIZE: Vector2 = Vector2(2620, 1720)
const MAP3_ARENA_SIZE: Vector2 = Vector2(2800, 1650)
const MAP3_BOUNDS_SIZE: Vector2 = Vector2(3120, 1970)
const MAP4_ARENA_SIZE: Vector2 = Vector2(3150, 1900)
const MAP4_BOUNDS_SIZE: Vector2 = Vector2(3470, 2220)
const MAP5_ARENA_SIZE: Vector2 = Vector2(2050, 1220)
const MAP5_BOUNDS_SIZE: Vector2 = Vector2(2370, 1540)
const MAP6_ARENA_SIZE: Vector2 = Vector2(3000, 1720)
const MAP6_BOUNDS_SIZE: Vector2 = Vector2(3320, 2040)
const MAP7_ARENA_SIZE: Vector2 = Vector2(2450, 1550)
const MAP7_BOUNDS_SIZE: Vector2 = Vector2(2770, 1870)
const MAP8_ARENA_SIZE: Vector2 = Vector2(3400, 1500)
const MAP8_BOUNDS_SIZE: Vector2 = Vector2(3720, 1820)
const MAP9_ARENA_SIZE: Vector2 = Vector2(1850, 1120)
const MAP9_BOUNDS_SIZE: Vector2 = Vector2(2170, 1440)
const MAP10_ARENA_SIZE: Vector2 = Vector2(3600, 2100)
const MAP10_BOUNDS_SIZE: Vector2 = Vector2(3920, 2420)
const MAP11_ARENA_SIZE: Vector2 = Vector2(3900, 1880)
const MAP11_BOUNDS_SIZE: Vector2 = Vector2(4220, 2200)
const SEARCH_STEP: float = 28.0
const SEARCH_DIRECTIONS: int = 18

@export var arena_center: Vector2 = Vector2(576, 324)
@export var obstacle_root_path: NodePath = ^"."

var selected_map_id: String = MAP1_ID
var active_obstacle_rects: Array[Rect2] = []
var obstacle_root: Node


func _ready() -> void:
	obstacle_root = get_node_or_null(obstacle_root_path)
	apply_map(MAP1_ID)


func apply_map(map_id: String) -> void:
	selected_map_id = map_id
	if obstacle_root:
		for child in obstacle_root.get_children():
			var child_name := String(child.name)
			if not child_name.begins_with("Map") or not child_name.ends_with("Obstacles"):
				continue
			var active := child_name == get_obstacle_group_name(map_id)
			child.visible = active
			set_collision_enabled_recursive(child, active)
	rebuild_obstacle_cache()


func get_arena_size() -> Vector2:
	match selected_map_id:
		MAP2_ID:
			return MAP2_ARENA_SIZE
		"map3":
			return MAP3_ARENA_SIZE
		"map4":
			return MAP4_ARENA_SIZE
		"map5":
			return MAP5_ARENA_SIZE
		"map6":
			return MAP6_ARENA_SIZE
		"map7":
			return MAP7_ARENA_SIZE
		"map8":
			return MAP8_ARENA_SIZE
		"map9":
			return MAP9_ARENA_SIZE
		"map10":
			return MAP10_ARENA_SIZE
		"map11":
			return MAP11_ARENA_SIZE
	return MAP1_ARENA_SIZE


func get_bounds_size() -> Vector2:
	match selected_map_id:
		MAP2_ID:
			return MAP2_BOUNDS_SIZE
		"map3":
			return MAP3_BOUNDS_SIZE
		"map4":
			return MAP4_BOUNDS_SIZE
		"map5":
			return MAP5_BOUNDS_SIZE
		"map6":
			return MAP6_BOUNDS_SIZE
		"map7":
			return MAP7_BOUNDS_SIZE
		"map8":
			return MAP8_BOUNDS_SIZE
		"map9":
			return MAP9_BOUNDS_SIZE
		"map10":
			return MAP10_BOUNDS_SIZE
		"map11":
			return MAP11_BOUNDS_SIZE
	return MAP1_BOUNDS_SIZE


func get_arena_rect() -> Rect2:
	var arena_size := get_arena_size()
	return Rect2(arena_center - arena_size / 2.0, arena_size)


func is_walkable(world_position: Vector2, clearance: float = 0.0) -> bool:
	if not get_arena_rect().grow(-clearance).has_point(world_position):
		return false
	for rect in active_obstacle_rects:
		if rect.grow(clearance).has_point(world_position):
			return false
	return true


func get_nearest_walkable_position(world_position: Vector2, clearance: float = 0.0) -> Vector2:
	var arena_rect := get_arena_rect().grow(-clearance)
	var clamped_position := Vector2(
		clamp(world_position.x, arena_rect.position.x, arena_rect.end.x),
		clamp(world_position.y, arena_rect.position.y, arena_rect.end.y)
	)
	if is_walkable(clamped_position, clearance):
		return clamped_position

	var base_angle := randf() * TAU
	for ring in range(1, 18):
		var radius := SEARCH_STEP * float(ring)
		for i in range(SEARCH_DIRECTIONS):
			var angle := base_angle + TAU * float(i) / float(SEARCH_DIRECTIONS)
			var candidate := clamped_position + Vector2.RIGHT.rotated(angle) * radius
			candidate.x = clamp(candidate.x, arena_rect.position.x, arena_rect.end.x)
			candidate.y = clamp(candidate.y, arena_rect.position.y, arena_rect.end.y)
			if is_walkable(candidate, clearance):
				return candidate

	return clamped_position


func resolve_actor_step(current_position: Vector2, target_position: Vector2, clearance: float) -> Vector2:
	if is_walkable(target_position, clearance):
		return target_position
	var x_only := Vector2(target_position.x, current_position.y)
	if is_walkable(x_only, clearance):
		return x_only
	var y_only := Vector2(current_position.x, target_position.y)
	if is_walkable(y_only, clearance):
		return y_only
	return get_nearest_walkable_position(current_position, clearance)


func rebuild_obstacle_cache() -> void:
	active_obstacle_rects.clear()
	var active_group := get_active_obstacle_group()
	if active_group == null:
		return
	for collision_shape in find_collision_shapes(active_group):
		if not collision_shape is CollisionShape2D:
			continue
		var shape := (collision_shape as CollisionShape2D).shape
		if shape is RectangleShape2D:
			var rect_size: Vector2 = (shape as RectangleShape2D).size * collision_shape.global_scale.abs()
			active_obstacle_rects.append(Rect2(collision_shape.global_position - rect_size / 2.0, rect_size))


func get_active_obstacle_group() -> Node:
	if obstacle_root == null:
		return null
	var group_name := get_obstacle_group_name(selected_map_id)
	if group_name == "":
		return null
	return obstacle_root.get_node_or_null(group_name)


func get_obstacle_group_name(map_id: String) -> String:
	match map_id:
		"map2":
			return "Map2Obstacles"
		"map3":
			return "Map3Obstacles"
		"map4":
			return "Map4Obstacles"
		"map5":
			return "Map5Obstacles"
		"map6":
			return "Map6Obstacles"
		"map7":
			return "Map7Obstacles"
		"map8":
			return "Map8Obstacles"
		"map9":
			return "Map9Obstacles"
		"map10":
			return "Map10Obstacles"
		"map11":
			return "Map11Obstacles"
	return ""


func find_collision_shapes(root: Node) -> Array[Node]:
	var result: Array[Node] = []
	for child in root.get_children():
		if child is CollisionShape2D:
			result.append(child)
		result.append_array(find_collision_shapes(child))
	return result


func set_collision_enabled_recursive(root: Node, enabled: bool) -> void:
	for child in root.get_children():
		if child is CollisionShape2D:
			(child as CollisionShape2D).disabled = not enabled
		set_collision_enabled_recursive(child, enabled)
