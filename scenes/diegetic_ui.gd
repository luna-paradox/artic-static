extends Node2D

@onready var player = $".."
@onready var energy_light = $energy_light
@onready var turbo_light = $turbo_light

func _process(_delta: float) -> void:
	if player.is_boosting:
		update_turbo_light_visibility(true)
	else:
		update_turbo_light_visibility(false)


func update_turbo_light_visibility(new_visibility) -> void:
	if turbo_light.visible == new_visibility:
		return
	
	turbo_light.visible = new_visibility
