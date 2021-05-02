shader_type canvas_item;

varying vec2 v_local_space;
varying float v_cell_type;
varying float influence;

float calculate_ball_influence(vec2 world_position, vec2 ball_position, float radius_squared) {
	vec2 to_ball = ball_position - world_position;
	
	return radius_squared / dot(to_ball, to_ball);
}

void vertex() {
	v_local_space = VERTEX;
	
	vec2 circle_position = vec2(64.0, 64.0) / 128.0;
	float circle_radius_squared = (8.0 / 128.0) * (16.0 / 128.0);
	influence = calculate_ball_influence(v_local_space, circle_position, circle_radius_squared);
    influence += calculate_ball_influence(v_local_space, circle_position + vec2(0, 0.2*sin(2.0*TIME)), circle_radius_squared);
    influence += calculate_ball_influence(v_local_space, circle_position + vec2(0.4*cos(2.0*TIME + 3.14), 0), circle_radius_squared);
    influence += calculate_ball_influence(v_local_space, circle_position + vec2(0.3*cos(TIME + 3.14), 0.7*sin(1.4*TIME + 2.0)), circle_radius_squared);
}

void fragment() {
	COLOR = vec4(influence, 0.0, 0.0, 1);
}