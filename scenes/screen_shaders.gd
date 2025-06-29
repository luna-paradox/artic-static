extends CanvasLayer

@onready var cold_shader = $cold_shader

func _ready() -> void:
	show()

func _process(delta: float) -> void:
	process_cold_shader(delta)

# ---- COLD OVERLAY SHADER ----
# These are used to lerp between values when changing to avoid an
# abrupt change
var current_cold_ratio: float = 0.0
var target_cold_ratio: float = 0.0

# Process algo for the cold shader
func process_cold_shader(delta: float):
	if current_cold_ratio <= 0.0 and target_cold_ratio <= 0.0:
		cold_shader.hide()
		return
	elif !cold_shader.visible:
		cold_shader.show()
	
	# If current is not target yet then move it a bit towards it
	if current_cold_ratio != target_cold_ratio:
		var ratio_delta = lerp(current_cold_ratio, target_cold_ratio, delta * 6.0)
		current_cold_ratio = ratio_delta
		
		update_cold_shader(current_cold_ratio)

# Update the Cold Shader depending on a ratio from 0.0 to 1.0
func update_cold_shader(ratio: float) -> void:
	if ratio > 1.0:
		ratio = 1.0
	elif ratio < 0.0:
		ratio = 0.0
	
	# wave_intensity [0.0, 0.2]
	# tint_strength [0.0, 0.3]
	var new_wave_intensity = 0.1 * ratio
	var new_tint_strength = 0.25 * ratio
	
	cold_shader.material["shader_parameter/wave_intensity"] = new_wave_intensity
	cold_shader.material["shader_parameter/tint_strength"] = new_tint_strength
