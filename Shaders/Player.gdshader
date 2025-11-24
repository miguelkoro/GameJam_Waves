shader_type canvas_item;

uniform int mode = 0; // 0 normal, 1 damage, 2 heal
uniform float intensity = 0.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    if (mode == 1) {
        // Daño: Parpadeo rojo
        float flicker = abs(sin(TIME * 11.0)) * intensity;
        tex.rgb = mix(tex.rgb, vec3(1.0, 0.2, 0.2), flicker);
    }
    else if (mode == 2) {
        // Curación: Brillo verde suave
        float pulse = (sin(TIME * 6.0) * 0.5 + 0.5) * intensity;
        tex.rgb = mix(tex.rgb, vec3(0.2, 1.0, 0.3), pulse * 0.4);
    }

    COLOR = tex;
}