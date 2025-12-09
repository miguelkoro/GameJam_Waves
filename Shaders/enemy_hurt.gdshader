shader_type canvas_item;

uniform float hit_flash : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	// Mezcla del color original con un blanco fuerte según el valor del flash
	tex.rgb = mix(tex.rgb, vec3(1.0), hit_flash);

	COLOR = tex;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
