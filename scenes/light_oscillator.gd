extends Node

var light: PointLight2D

var base_energy: float = 1.0

@export var energy_delta: float = 0.5
@export var frequency: float = 2.0

func _ready() -> void:
	light = get_parent() as PointLight2D
	base_energy = light.energy

func _process(_delta: float) -> void:
	var time: float = Time.get_ticks_msec() / 1000.0
	
	var amplitude: float = energy_delta / 2.0
	var sin_modifier: float = amplitude * sin(time * frequency) + (1 - amplitude)
	light.energy = base_energy * sin_modifier
