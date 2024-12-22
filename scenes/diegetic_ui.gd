extends Node2D

@onready var player = $".."
@onready var main = $"../.."
@onready var energy_light = $energy_light
@onready var energy_light_point = $energy_light/light
@onready var turbo_light = $turbo_light

func _process(_delta: float) -> void:
	if player.is_boosting:
		update_turbo_light_visibility(true)
	else:
		update_turbo_light_visibility(false)
	
	var energy_percentage: float = float(main.current_energy) / main.MAX_ENERGY
	update_energy_light_alpha(energy_percentage)


func update_turbo_light_visibility(new_visibility) -> void:
	if turbo_light.visible == new_visibility:
		return
	
	turbo_light.visible = new_visibility

func update_energy_light_alpha(alpha_percentage: float) -> void:
	energy_light.modulate.a = alpha_percentage
	energy_light_point.energy = alpha_percentage * 16
