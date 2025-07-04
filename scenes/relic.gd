extends Node2D

@onready var sprite = $sprite

var scanning_enabled: bool = false
var custom_scanning_time: float = 0.0

var scanned_percentage: float = 0.0
var was_scanned: bool = false

func scan(delta: float):
	scanned_percentage += delta
	print('SCANNING: ' + str(scanned_percentage))
	if scanned_percentage < 100.0:
		return
	
	was_scanned = true
	
	#update_scanning(true)
	#await get_tree().create_timer(3.0).timeout  # waits 2 seconds
	#update_scanning(false)
	pass

func update_scanning(new_state: bool) -> void:
	sprite.material.set_shader_parameter("enabled", new_state)
	scanning_enabled = new_state
	if new_state:
		custom_scanning_time = 0.0

func _process(delta):
	if scanning_enabled:
		custom_scanning_time += delta
		sprite.material.set_shader_parameter("custom_time", custom_scanning_time)
