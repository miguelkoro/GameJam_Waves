shader_type canvas_item;

uniform float speed = 2.0;      // velocidad del parpadeo
uniform float amplitude = 0.1;  // cuánto se ilumina

void fragment() {
    vec4 col = texture(TEXTURE, UV);
    
    // Oscilación simple de brillo
    float glow = sin(TIME * speed) * amplitude;
    col.rgb += glow;
    
    COLOR = col;
}
