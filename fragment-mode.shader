shader_type canvas_item;
render_mode blend_mix;

varying vec2 v_world_space;

void vertex() {
	v_world_space = (WORLD_MATRIX * vec4(VERTEX, 1.0, 1.0)).xy;
}

void fragment() {
	vec2 centers[2];
	float radii[2];
	
	centers[0].x = 64.0;
	centers[0].y = 96.0*sin(TIME);
	radii[0] = 32.0;
	
	centers[1].x = 104.0*cos(TIME);
	centers[1].y = 64.0;
	radii[1] = 32.0;
	
	float accum = 0.0;
	for (int i = 0; i < 2; i++) {
		vec2 offset = v_world_space - centers[i];
		accum += (radii[i] * radii[i]) / dot(offset, offset);
	}
	
	if (accum >= 1.0) {
		COLOR = vec4(UV.xy, 1.0, 1.0);
	} else {
		discard;
	}
}
