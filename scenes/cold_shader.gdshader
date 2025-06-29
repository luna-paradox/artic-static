shader_type canvas_item;

// Required for screen sampling in Godot 4.3+
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float wave_intensity : hint_range(0.0, 1.0) = 0.2;
uniform float tint_strength : hint_range(0.0, 1.0) = 0.3;
uniform vec3 tint_color : source_color = vec3(0.090, 0.278, 0.306);

void fragment() {
    vec2 uv = SCREEN_UV;

    // Wavy shimmer for icy distortion
    uv.y += sin(uv.x * 40.0 + TIME * 3.0) * 0.003 * wave_intensity;
    uv.x += cos(uv.y * 30.0 + TIME * 2.0) * 0.003 * wave_intensity;

    vec4 screen_color = texture(SCREEN_TEXTURE, uv);

    // Cyan cold tint
    screen_color.rgb = mix(screen_color.rgb, tint_color, tint_strength);

    COLOR = screen_color;
}