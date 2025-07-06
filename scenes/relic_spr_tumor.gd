extends Node2D

@export var pulse_speed: float = 2.0        # Pulses per second
@export var pulse_strength: float = 0.03     # How much to scale
@export var pulse_interval: float = 1.5     # Time between pulses (in seconds)

var pulse_timer: Timer
var pulse_progress: float = 0.0             # In radians
var is_pulsing: bool = false
var shader_mat: ShaderMaterial

func toogle_mode(is_strong: bool) -> void:
	if is_strong:
		pulse_speed = 5.0
		pulse_strength = 0.05
		pulse_interval = 0.5
	else:
		pulse_speed = 2.0
		pulse_strength = 0.03
		pulse_interval = 1.5
	
	shader_mat.set_shader_parameter("pulse_strength", pulse_strength)
	pulse_timer.wait_time = pulse_interval


func _ready():
	shader_mat = material as ShaderMaterial
	
	pulse_timer = Timer.new()
	pulse_timer.wait_time = pulse_interval
	pulse_timer.one_shot = false
	pulse_timer.autostart = true
	add_child(pulse_timer)
	pulse_timer.timeout.connect(trigger_pulse)
	
	toogle_mode(false)

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
