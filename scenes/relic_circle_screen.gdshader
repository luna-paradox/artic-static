shader_type canvas_item;

uniform bool enable_wave_2 = true;

uniform float time_mult = 2.0;
uniform float frequency = 15.0;
uniform float amplitude = 0.01;

uniform float time_mult_2 = 15.0;
uniform float frequency_2 = 30.0;
uniform float amplitude_2 = 0.02;

uniform vec4 wave_color = vec4(0.0, 1.0, 0.0, 1.0); // GREEN wave
uniform vec4 wave_color_2 = vec4(1.0, 0.0, 0.0, 1.0); // RED wave
uniform vec4 black = vec4(0.0, 0.0, 0.0, 1.0);
uniform float thickness = 0.003;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    if (tex.a <= 0.0) {
        discard;
    }

    float wave = 0.5 + sin(UV.x * frequency * 6.283 + (TIME * time_mult) * 2.0) * amplitude - 0.134;
    float wave_2 = 0.5 + sin(UV.x * frequency_2 * 6.283 + (TIME * time_mult_2) * 2.0) * amplitude_2 - 0.134;
	float final_wave = 0.0;
	if (enable_wave_2) {
		final_wave = wave + wave_2 - 0.37;
	} else {
		final_wave = wave;
	}
	float dist = abs(UV.y - final_wave);

    if (dist < thickness) {
		if (enable_wave_2) {
	        COLOR = wave_color_2;
		} else {
	        COLOR = wave_color;
		}
    } else {
        COLOR = black;
    }
}
