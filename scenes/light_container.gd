extends Node2D

@onready var light_origin = $"../light_origin"


func _process(_delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	var angle =  light_origin.get_angle_to(mouse_pos)
	rotation = angle
