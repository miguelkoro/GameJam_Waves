shader_type canvas_item;

// Intensidad del efecto de tinta (0.0 = invisible, 1.0 = máximo)
uniform float intensity : hint_range(0.0, 1.0) = 0.0;

// Textura de ruido para dar patrón irregular a la tinta
uniform sampler2D noise_tex;

// Velocidad a la que la tinta “cae” hacia abajo
uniform float fall_speed : hint_range(0.0, 1.0) = 0.01;

// Offset vertical acumulado para animar la caída
uniform float time_passed = 0.0;

void fragment() {
    // Desplazamos la textura de ruido verticalmente según el tiempo
    vec2 uv_offset = UV + vec2(0.0, time_passed * fall_speed);

    // Obtenemos valor de ruido
    vec4 noise = texture(noise_tex, uv_offset);

    // Calculamos la alpha del efecto según el ruido y la intensidad
    float ink_alpha = noise.r * intensity;

    // Tinta negra sobre transparente
    COLOR = vec4(0.0, 0.0, 0.0, ink_alpha);
}