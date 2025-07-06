shader_type canvas_item;

// --- General ---
uniform bool enabled = true;
uniform float custom_time = 0.0;
uniform vec4 black = vec4(0.0, 0.0, 0.0, 1.0);

// --- Wave Logic ---
uniform bool enable_wave_2 = true;

uniform float time_mult = 2.0;
uniform float frequency = 15.0;
uniform float amplitude = 0.01;

uniform float time_mult_2 = 15.0;
uniform float frequency_2 = 30.0;
uniform float amplitude_2 = 0.02;

uniform vec4 wave_color = vec4(0.0, 1.0, 0.0, 1.0);
uniform vec4 wave_color_2 = vec4(1.0, 0.0, 0.0, 1.0);
uniform float thickness = 0.003;

// --- CRT Effect ---
uniform float scan_speed = 1.0;
uniform float scan_thickness = 4.0;
uniform vec4 scan_color = vec4(0.0, 1.0, 0.0, 1.0);

uniform float scanline_strength = 0.15;
uniform float chromatic_offset = 1.0;
uniform float noise_strength = 0.05;
uniform float flicker_speed = 2.0;

// --- Grid Overlay ---
uniform vec2 image_size = vec2(450.0, 300.0);
uniform float grid_cell_size = 15.0;
uniform float grid_line_thickness = 1.0;
uniform vec4 grid_color = vec4(0.0, 1.0, 0.0, 0.3);

float rand(vec2 co) {
    return fract(sin(dot(co.xy ,vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = UV;
    vec4 tex_color = texture(TEXTURE, uv);
	
    // Discard fully transparent pixels
    if (tex_color.a <= 0.0) {
        discard;
    }
	
    vec4 base_color = black;

    // --- CRT OVERLAY ---
    if (enabled) {
        // Chromatic aberration
        float offset = chromatic_offset / 1000.0;
        base_color.r = texture(TEXTURE, uv + vec2(offset, 0.0)).r;
        base_color.g = texture(TEXTURE, uv).g;
        base_color.b = texture(TEXTURE, uv - vec2(offset, 0.0)).b;

        // Scanning line
        float scan_pos = abs(sin(custom_time * scan_speed));
        float scan_dist = abs(uv.y - scan_pos);
        float scanline = smoothstep(scan_thickness / 100.0, 0.0, scan_dist);
        base_color.rgb = mix(base_color.rgb, scan_color.rgb, scanline);

        // Horizontal CRT scanlines
        float h_scan = sin(uv.y * 800.0) * scanline_strength;
        base_color.rgb -= h_scan;

        // Flicker
        float flicker = 1.0 + (sin(TIME * flicker_speed) * 0.1);
        base_color.rgb *= flicker;

        // Noise
        float noise = rand(vec2(uv.x * TIME, uv.y * TIME)) * noise_strength;
        base_color.rgb += noise;

        // --- GRID LINES ---
        vec2 pixel_pos = uv * image_size;
        float mod_x = mod(pixel_pos.x, grid_cell_size);
        float mod_y = mod(pixel_pos.y, grid_cell_size);
        float dist_x = min(mod_x, grid_cell_size - mod_x);
        float dist_y = min(mod_y, grid_cell_size - mod_y);

        float grid_x = smoothstep(grid_line_thickness + 0.5, 0.5, dist_x);
        float grid_y = smoothstep(grid_line_thickness + 0.5, 0.5, dist_y);
        float grid_line = max(grid_x, grid_y);

        base_color.rgb = mix(base_color.rgb, grid_color.rgb, grid_line * grid_color.a);
    }

    // --- WAVE DRAWING ---
    float wave = 0.5 + sin(uv.x * frequency * 6.283 + (TIME * time_mult) * 2.0) * amplitude - 0.134;
    float wave_2 = 0.5 + sin(uv.x * frequency_2 * 6.283 + (TIME * time_mult_2) * 2.0) * amplitude_2 - 0.134;

    float final_wave = enable_wave_2 ? (wave + wave_2 - 0.37) : wave;
    float dist = abs(uv.y - final_wave);

    bool drawing_wave = dist < thickness;

    // Determine base color (either wave or black (default))
    if (drawing_wave) {
        base_color = enable_wave_2 ? wave_color_2 : wave_color;
    }

    COLOR = base_color;
}
