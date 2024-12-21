extends Node2D

@onready var interaction_collider = $interaction_area/collider
@onready var light = $light
@onready var bg = $bg
@onready var static_ooze = $static_ooze

@export var max_static_amount = 300.0
var current_static_amount = 300.0

var enabled = true

func _ready() -> void:
	var r = randi() % 50 + 1
	r = r/100.0
	r += 0.5
	max_static_amount = max_static_amount * r
	
	current_static_amount = max_static_amount
	set_meta('type', 'STATIC_NODE')
	original_light_strenght = light.energy

#func _process(delta: float) -> void:
	#consume(delta * 100)

# Consume the node. The delta_rate should be low to be used from _process
# It returns if the node is depleted or not
func consume(delta_rate: float) -> bool:
	current_static_amount -= delta_rate
	
	if current_static_amount > max_static_amount:
		current_static_amount = max_static_amount
	elif current_static_amount < 0:
		current_static_amount = 0
	
	var proportions = current_static_amount / max_static_amount
	light.energy = 5 * proportions
	
	var is_depleted = current_static_amount <= 0
	
	if is_depleted:
		disable()
	
	return is_depleted

func disable() -> void:
	interaction_collider.disabled = true
	static_ooze.hide()
	bg.hide()
	enabled = false

var original_light_strenght: float

func reset() -> void:
	current_static_amount = max_static_amount
	interaction_collider.disabled = false
	static_ooze.show()
	bg.show()
	light.energy = original_light_strenght
	enabled = true
	
