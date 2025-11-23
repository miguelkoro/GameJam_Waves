shader_type canvas_item;

uniform float flash_speed : hint_range(1.0, 20.0) = 10.0;
uniform float flash_intensity : hint_range(0.0, 1.0) = 0.5;
uniform float active : hint_range(0.0,1.0) = 0.0;

void fragment() {
    // Color original del sprite
    vec4 tex = texture(TEXTURE, UV);

    // Si el parpadeo está activo
    if (active > 0.0) {
        // Genera un valor oscilante entre 0 y 1
        float t = abs(sin(TIME * flash_speed));
        // Mezcla entre rojo y el color original
        COLOR = mix(tex, vec4(1.0,0.0,0.0,tex.a), t * flash_intensity);
    } else {
        COLOR = tex;
    }
}