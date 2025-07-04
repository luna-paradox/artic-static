extends Node2D

@onready var sprite = $sprite

# If the relic is being scanned right now
var scanning_enabled: bool = false
var custom_scanning_time: float = 0.0

var scanned_percentage: float = 0.0
# if the relic was scanned completely
var was_scanned: bool = false

func reset():
	scanning_enabled = true
	custom_scanning_time = 0.0
	scanned_percentage = 0.0
	was_scanned = false

func scan(delta: float):
	scanned_percentage += delta
	#print('SCANNING: ' + str(scanned_percentage))
	if scanned_percentage < 100.0:
		return
	was_scanned = true

func update_scanning(new_state: bool) -> void:
	sprite.material.set_shader_parameter("enabled", new_state)
	scanning_enabled = new_state
	if new_state:
		custom_scanning_time = 0.0

func _process(delta):
	if scanning_enabled:
		custom_scanning_time += delta
		sprite.material.set_shader_parameter("custom_time", custom_scanning_time)
