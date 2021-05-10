shader_type canvas_item;

uniform sampler2D u_circles_position_radius_squared; // One dimensional, values are <circle_x, circle_y, radius_squared, unused>
uniform float u_circle_count;

uniform sampler2D u_color_ramp; // One dimensional, sampled by clamped_total_influence / u_max_intensity
uniform float u_max_intensity;  // Total influence clamped by this amount

uniform vec2 u_circle_position_offset; // Workaround 0..1 clamping
uniform vec2 u_circle_position_scale; 
uniform float u_circle_radius_squared_scale;


varying float v_influence;


// Calculates center
vec2 calculate_circle_uv(int circle_index) {
	float texel_width = 1.0 / u_circle_count;
	float tl_xcoord = float(circle_index) / u_circle_count;
	float center_xcoord = tl_xcoord + texel_width / 2.0;
	
	return vec2(center_xcoord, 0.5);
}

vec4 get_circle_position_radius(int circle_index) {
	vec4 raw_circle_position_radius = texture(u_circles_position_radius_squared, calculate_circle_uv(circle_index));
	vec2 position = u_circle_position_scale * raw_circle_position_radius.xy + u_circle_position_offset;
	float radius_squared = u_circle_radius_squared_scale * raw_circle_position_radius.z;
	
	vec4 scaled_circle_position_radius = vec4(
		position,
		radius_squared,
		raw_circle_position_radius.w
	);
	
	return scaled_circle_position_radius;
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
		vec4 circle_position_radius = get_circle_position_radius(circle_index);
		vec2 circle_position = circle_position_radius.xy;
		float circle_radius_squared = circle_position_radius.z;
		
		influence += calculate_ball_influence(position, circle_position, circle_radius_squared);
	}
	
	return influence;
}


void vertex() {
	v_influence = sum_ball_influence(VERTEX);
}


void fragment() {
	float influence_clamped = clamp(v_influence, 0.0, u_max_intensity);
	float influence_clamped_normalized = influence_clamped / u_max_intensity;
	
	COLOR = texture(u_color_ramp, vec2(influence_clamped_normalized, 0.0));
}
