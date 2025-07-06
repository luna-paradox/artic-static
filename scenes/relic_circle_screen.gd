extends Sprite2D

@onready var mat: ShaderMaterial = material

func toggle_wave_2(new_state: bool) -> void:
	mat.set_shader_parameter("enable_wave_2", new_state)
