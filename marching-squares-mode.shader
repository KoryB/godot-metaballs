shader_type canvas_item;

uniform vec2 u_local_cell_size;

varying vec2 v_local_position;
varying float v_marching_squares_index;

float calculate_ball_influence(vec2 position, vec2 ball_position, float radius_squared) {
	vec2 to_ball = ball_position - position;
	float distance_squared = dot(to_ball, to_ball) + 0.00001; // avoid divide by zero (kinda)
	
	return radius_squared / distance_squared;
}

void vertex() {
	vec2 circle_position = vec2(0.5, 0.5);
	float circle_radius = 0.25;

	vec2 cell_positions[4]; // tl, tr, bl, br
	float influences[4];
	int marching_squares_index;

	cell_positions[0] = VERTEX - UV * u_local_cell_size;
    cell_positions[1] = cell_positions[0] + vec2(1, 0) * u_local_cell_size;
	cell_positions[2] = cell_positions[0] + vec2(0, 1) * u_local_cell_size;
	cell_positions[3] = cell_positions[1] + cell_positions[2] - cell_positions[0]; // tl_vertex + vec2(1, 1) * u_local_cell_size

	for (int i = 0; i < 4; i++) {
		vec2 position = cell_positions[i];

		influences[i] = calculate_ball_influence(position, circle_position, circle_radius*circle_radius);
		influences[i] = (sign(influences[i] - 1.0) + 1.0) / 2.0; // convert to 'on' or 'off'
	}

	marching_squares_index = int(influences[0] + 2.0*influences[1] + 4.0*influences[2] + 8.0*influences[3]);
	UV.x = UV.x * u_local_cell_size.x + float((marching_squares_index % 4)) / 4.0;
	UV.y = UV.y * u_local_cell_size.y + float(marching_squares_index / 4) / 4.0;

	v_local_position = VERTEX;
	v_marching_squares_index = float(marching_squares_index) / 15.0;
}

void fragment() {
	vec2 circle_position = vec2(0.5, 0.5);
	float circle_radius = 0.25;

	float influence = calculate_ball_influence(v_local_position, circle_position, circle_radius*circle_radius);
	influence = clamp(influence, 0.0, 1.0);

	COLOR.rgb = texture(TEXTURE, UV).rgb;
	COLOR.a = 1.0;
	
	// COLOR = vec4(UV.x / 3.0, 0.0, 0.0, 1.0);
}