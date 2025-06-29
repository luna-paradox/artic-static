extends Node

@export var max_enabled_lights: int = 16
@export var reference_node: Node2D
@export var update_interval: float = 0.25  # Seconds between updates

var _timer: float = 0.0

func _process(delta: float) -> void:
	enable_closer_lights(delta)

# Enable the max_enabled_lights closer to reference_node
# Only checks every update_interval seconds
func enable_closer_lights(delta: float) -> void:
	if reference_node == null:
		return
	
	# Only check ever update_interval seconds
	_timer -= delta
	if _timer > 0.0:
		return
	_timer = update_interval
	
	# Get all lights in the scene
	var root_node = get_tree().root
	var lights: Array = get_all_light2d_nodes(root_node)
	
	# Sort them by proximity (could it be faster?)
	lights.sort_custom(func(a: Light2D, b: Light2D):
		var reference_pos: Vector2 = reference_node.global_position
		var a_distance: float = a.global_position.distance_to(reference_pos)
		var b_distance: float = b.global_position.distance_to(reference_pos)
		return a_distance < b_distance
	)
	
	# Enable the max_enabled_light closer to the reference_node and disable the rest
	for i in range(lights.size()):
		var light: Light2D = lights[i]
		light.enabled = i < max_enabled_lights

# Get all light2d nodes in the scene recursively throgh the tree 
func get_all_light2d_nodes(root: Node) -> Array:
	var lights: Array = []
	for child in root.get_children():
		if child is Light2D:
			lights.append(child)
		if child.get_child_count() > 0:
			lights += get_all_light2d_nodes(child)
	return lights
