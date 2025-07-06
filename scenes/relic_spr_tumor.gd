extends Node2D

@export var pulse_speed: float = 2.0        # Pulses per second
@export var pulse_strength: float = 0.03     # How much to scale
@export var pulse_interval: float = 1.5     # Time between pulses (in seconds)

var pulse_progress: float = 0.0             # In radians
var is_pulsing: bool = false
var shader_mat: ShaderMaterial

func _ready():
	shader_mat = material as ShaderMaterial
	shader_mat.set_shader_parameter("pulse_strength", pulse_strength)
	
	var timer := Timer.new()
	timer.wait_time = pulse_interval
	timer.one_shot = false
	timer.autostart = true
	add_child(timer)
	timer.timeout.connect(trigger_pulse)

func _process(delta: float):
	if is_pulsing:
		pulse_progress += delta * PI * pulse_speed  # from 0 to π
		shader_mat.set_shader_parameter("pulse_value", pulse_progress)

		if pulse_progress >= PI:
			shader_mat.set_shader_parameter("pulse_value", 0.0)
			pulse_progress = 0.0
			is_pulsing = false

func trigger_pulse():
	is_pulsing = true
	pulse_progress = 0.0
