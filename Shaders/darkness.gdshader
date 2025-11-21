shader_type canvas_item;

uniform float darkness : hint_range(0.0, 1.0) = 0.6;

void fragment() {
    // UV centrado (0,0) en el centro de pantalla, 1 en bordes
    vec2 uv = SCREEN_UV * 2.0 - 1.0;
    float dist = length(uv);

    // Oscurece más lejos del centro (tipo vignette)
    float vignette = smoothstep(0.3, 1.0, dist);

    COLOR = vec4(0.0, 0.0, 0.0, vignette * darkness);
}