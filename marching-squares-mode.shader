shader_type canvas_item;

uniform vec2 u_local_cell_size;

uniform sampler2D u_circles_position_radius_squared; // One dimensional, values are <circle_x, circle_y, radius_squared, unused>
uniform float u_circle_count;

uniform sampler2D u_color_ramp; // One dimensional, sampled by clamped_total_influence / u_max_intensity
uniform float u_max_intensity;  // Total influence clamped by this amount


float calculate_ball_influence(vec2 position, vec2 ball_position, float radius_squared) {
	vec2 to_ball = ball_position - position;
	float distance_squared = dot(to_ball, to_ball) + 0.00001; // avoid divide by zero (kinda)
	
	return radius_squared / distance_squared;
}

void vertex() {
	vec2 cell_positions[4]; // tl, tr, bl, br
	float influences[4];
	int marching_squares_index;
	int circle_count_int = int(u_circle_count);

	cell_positions[0] = VERTEX - UV * u_local_cell_size;
    cell_positions[1] = cell_positions[0] + vec2(1, 0) * u_local_cell_size;
	cell_positions[3] = cell_positions[0] + vec2(0, 1) * u_local_cell_size;
	cell_positions[2] = cell_positions[1] + cell_positions[3] - cell_positions[0]; // tl_vertex + vec2(1, 1) * u_local_cell_size

	for (int cell_index = 0; cell_index < 4; cell_index++) {
		vec2 position = cell_positions[cell_index];
		influences[cell_index] = 0.0;

		for (int circle_index = 0; circle_index < circle_count_int; circle_index++) {
			vec4 circle_position_radius = texture(u_circles_position_radius_squared, vec2(float(circle_index) / u_circle_count, 0.0));
			vec2 circle_position = circle_position_radius.xy;
			float circle_radius_squared = circle_position_radius.z;
			
			influences[cell_index] += calculate_ball_influence(position, circle_position, circle_radius_squared);
		}
		
		influences[cell_index] = (sign(influences[cell_index] - 1.0) + 1.0) / 2.0; // convert to 'on' or 'off'
	}

	marching_squares_index = int(influences[0] + 2.0*influences[1] + 4.0*influences[2] + 8.0*influences[3]);
	
	UV.x = UV.x * 0.25 + float(marching_squares_index % 4) / 4.0;
	UV.y = UV.y * 0.25 + float(marching_squares_index / 4) / 4.0;
}