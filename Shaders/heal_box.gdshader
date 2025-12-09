shader_type canvas_item;


uniform bool healing = false;
uniform float pulse_speed : hint_range(0.1, 10.0) = 1.0;
uniform vec4 glow_color : source_color = vec4(0.0, 1.0, 0.0, 1.0); // Verde

void fragment() {
    vec4 base = texture(TEXTURE, UV);

    if (healing) {
        // Pulso sinusoidal entre 0 y 1
        float glow = (sin(TIME * pulse_speed) + 1.0) * 0.5;

        // Mezclamos el color base con el verde
        base.rgb = mix(base.rgb, glow_color.rgb, glow * 0.4); 
    }

    COLOR = base;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
