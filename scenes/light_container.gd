extends Node2D

var light_origin

func _ready() -> void:
	var main = get_parent()
	light_origin = main.get_node("light_origin")

func _process(_delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	var angle = light_origin.get_angle_to(mouse_pos)
	rotation = angle
