shader_type canvas_item;

uniform float pixel_size = 8.0;
uniform float shade_strength = 0.2;

void fragment() {
    vec2 uv = UV;

    // Pixelisation
    uv = floor(uv * pixel_size) / pixel_size;

    vec4 col = texture(TEXTURE, uv);

    // Fake shading voxel (grille simple)
    float grid_x = step(0.5, fract(UV.x * pixel_size));
    float grid_y = step(0.5, fract(UV.y * pixel_size));
    float shadow = grid_x * grid_y;

    col.rgb *= mix(0.8, 1.0, shadow * shade_strength);

    COLOR = col;
}