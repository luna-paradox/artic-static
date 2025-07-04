shader_type canvas_item;

// Toggle entire effect
uniform bool enabled = true;

uniform float custom_time = 0.0;

// Green scanline
uniform float scan_speed : hint_range(0.1, 10.0) = 1.0;
uniform float scan_thickness : hint_range(1.0, 20.0) = 4.0;
uniform vec4 scan_color : source_color = vec4(0.0, 1.0, 0.0, 1.0);

// CRT scanlines
uniform float scanline_strength : hint_range(0.0, 0.5) = 0.15;

// RGB offset
uniform float chromatic_offset : hint_range(0.0, 5.0) = 1.0;

// Flicker / noise
uniform float noise_strength : hint_range(0.0, 0.3) = 0.05;
uniform float flicker_speed : hint_range(0.1, 10.0) = 2.0;

// Grid settings
uniform vec2 image_size = vec2(450.0, 300.0); // in pixels
uniform float grid_cell_size = 15.0;
uniform float grid_line_thickness = 1.0; // in pixels
uniform vec4 grid_color : source_color = vec4(0.0, 1.0, 0.0, 0.3); // semi-transparent green

float rand(vec2 co) {
    return fract(sin(dot(co.xy ,vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = UV;
    vec4 tex_color = texture(TEXTURE, uv);

    if (enabled && tex_color.a > 0.0) {
        // Chromatic aberration
        float offset = chromatic_offset / 1000.0;
        tex_color.r = texture(TEXTURE, uv + vec2(offset, 0.0)).r;
        tex_color.g = texture(TEXTURE, uv).g;
        tex_color.b = texture(TEXTURE, uv - vec2(offset, 0.0)).b;

        // Green scanning line
        float scan_pos = abs(sin(custom_time * scan_speed));
        float dist = abs(uv.y - scan_pos);
        float scanline = smoothstep(scan_thickness / 100.0, 0.0, dist);
        tex_color.rgb = mix(tex_color.rgb, scan_color.rgb, scanline);

        // Horizontal CRT scanlines
        float h_scan = sin(uv.y * 800.0) * scanline_strength;
        tex_color.rgb -= h_scan;

        // Flicker
        float flicker = 1.0 + (sin(TIME * flicker_speed) * 0.1);

        // Noise
        float noise = rand(vec2(uv.x * TIME, uv.y * TIME)) * noise_strength;

        tex_color.rgb *= flicker;
        tex_color.rgb += noise;

        // --- GRID OVERLAY ---
        // Convert UV to pixel coords relative to image size
        vec2 pixel_pos = uv * image_size;

        // Find position within cell
        float mod_x = mod(pixel_pos.x, grid_cell_size);
        float mod_y = mod(pixel_pos.y, grid_cell_size);

        // Distance to nearest vertical or horizontal grid line
        float line_dist_x = min(mod_x, grid_cell_size - mod_x);
        float line_dist_y = min(mod_y, grid_cell_size - mod_y);

        // Check if within line thickness on either axis
        float grid_line_x = smoothstep(grid_line_thickness + 0.5, 0.5, line_dist_x);
        float grid_line_y = smoothstep(grid_line_thickness + 0.5, 0.5, line_dist_y);

        float grid_line = max(grid_line_x, grid_line_y);

        // Blend grid line over texture
        tex_color.rgb = mix(tex_color.rgb, grid_color.rgb, grid_line * grid_color.a);
    }

    COLOR = tex_color;
}
