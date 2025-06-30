extends Node

var light: PointLight2D

@export var low_energy: float = 1.0
@export var high_energy: float = 3.0
@export var time_in_high: float = 0.3
@export var time_in_low: float = 1.0

func _ready() -> void:
	light = get_parent() as PointLight2D
	update_high(is_high)

var counter: float = 0.0
var is_high: bool = false

func _process(delta: float) -> void:
	if is_high and counter < time_in_high:
		counter += delta
	elif is_high:
		update_high(false)
	elif !is_high and counter < time_in_low:
		counter += delta
	else:
		update_high(true)

func update_high(new_state: bool):
	is_high = new_state
	counter = 0.0
	if is_high:
		light.energy = high_energy
	else:
		light.energy = low_energy
