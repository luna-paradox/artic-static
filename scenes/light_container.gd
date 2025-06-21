extends Node2D

@onready var light_origin = $"../light_origin"
@onready var light = $"light"
@onready var light_occluder = $"light_occluder"


func _process(_delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	var angle =  light_origin.get_angle_to(mouse_pos)
	rotation = angle
	
	light.show()
	light_occluder.show()
