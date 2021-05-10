shader_type canvas_item;

uniform sampler2D u_circles_position_radius_squared; // One dimensional, values are <circle_x, circle_y, radius_squared, unused>
uniform float u_circle_count;

uniform sampler2D u_color_ramp; // One dimensional, sampled by clamped_total_influence / u_max_intensity
uniform float u_max_intensity;  // Total influence clamped by this amount


varying vec2 v_local_space;


// Calculates center
vec2 calculate_circle_uv(int circle_index) {
	float texel_width = 1.0 / u_circle_count;
	float tl_xcoord = float(circle_index) / u_circle_count;
	float center_xcoord = tl_xcoord + texel_width / 2.0;
	
	return vec2(center_xcoord, 0.5);
}

float calculate_ball_influence(vec2 position, vec2 ball_position, float radius_squared) {
	vec2 to_ball = ball_position - position;
	float distance_squared = dot(to_ball, to_ball) + 0.00001; // avoid divide by zero (kinda)
	
	return radius_squared / distance_squared;
}

float sum_ball_influence(vec2 position) {
	int circle_count_int = int(u_circle_count);
	float influence = 0.0;

	for (int circle_index = 0; circle_index < circle_count_int; circle_index++) {
		vec4 circle_position_radius = texture(u_circles_position_radius_squared, calculate_circle_uv(circle_index));
		vec2 circle_position = circle_position_radius.xy;
		float circle_radius_squared = circle_position_radius.z;
		
		influence += calculate_ball_influence(position, circle_position, circle_radius_squared);
	}
	
	return influence;
}


void vertex() {
	v_local_space = VERTEX;
}


void fragment() {
	float influence = sum_ball_influence(v_local_space);
	float influence_clamped = clamp(influence, 0.0, u_max_intensity);
	float influence_clamped_normalized = influence_clamped / u_max_intensity;
	
	COLOR = texture(u_color_ramp, vec2(influence_clamped_normalized, 0.0));
}
