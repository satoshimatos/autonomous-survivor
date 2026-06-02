class_name RuntimeQuery
extends RefCounted


static func get_active_enemies(context: Node) -> Array:
	return get_cached_or_group_nodes(context, "Enemy", "get_active_enemies")


static func get_active_exp_orbs(context: Node) -> Array:
	return get_cached_or_group_nodes(context, "ExpOrb", "get_active_exp_orbs")


static func get_cached_or_group_nodes(context: Node, group_name: String, cache_method: StringName) -> Array:
	if context == null or not context.is_inside_tree():
		return []
	var tree := context.get_tree()
	var main := tree.current_scene
	if main and main.has_method(cache_method):
		return main.call(cache_method)
	return tree.get_nodes_in_group(group_name)
