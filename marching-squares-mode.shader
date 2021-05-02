shader_type canvas_item;

varying vec2 v_local_space;
varying float v_cell_type;
varying float influence;

float calculate_ball_influence(vec2 world_position, vec2 ball_position, float radius_squared) {
	vec2 to_ball = ball_position - world_position;
	float distance_squared = dot(to_ball, to_ball) + 0.00001;
	
	return radius_squared / distance_squared;
}

void vertex() {
	v_local_space = VERTEX;
	float tTIME = sin(TIME);
	
	vec2 circle_position = vec2(64.0, 62.0-tTIME) / 128.0;
	float circle_radius_squared = (8.0 / 128.0) * (8.0 / 128.0);
	influence = 0.0;
	influence += calculate_ball_influence(v_local_space, circle_position, circle_radius_squared);
    //influence += calculate_ball_influence(v_local_space, circle_position + vec2(0, 0.2*sin(2.0*tTIME)), circle_radius_squared);
    //influence += calculate_ball_influence(v_local_space, circle_position + vec2(0.4*cos(2.0*tTIME + 3.14), 0), circle_radius_squared);
    //influence += calculate_ball_influence(v_local_space, circle_position + vec2(0.3*cos(tTIME + 3.14), 0.7*sin(1.4*tTIME + 2.0)), circle_radius_squared);
}

void fragment() {
	float tTIME = sin(TIME);
	
	vec2 circle_position = vec2(64.0, 62.0) / 128.0;
	float circle_radius_squared = (32.0 / 128.0) * (8.0 / 128.0);
	
	float inf = calculate_ball_influence(v_local_space, circle_position, circle_radius_squared);
    inf += calculate_ball_influence(v_local_space, circle_position + vec2(0, 0.2*sin(2.0*tTIME)), circle_radius_squared);
    inf += calculate_ball_influence(v_local_space, circle_position + vec2(0.4*cos(2.0*tTIME + 3.14), 0), circle_radius_squared);
    inf += calculate_ball_influence(v_local_space, circle_position + vec2(0.3*cos(tTIME + 3.14), 0.7*sin(1.4*tTIME + 2.0)), circle_radius_squared);
	// inf = influence;
	
	inf = inf / 100.0;
	
	COLOR = vec4(inf*inf*inf, 0.0, 0.0, inf*inf*inf*inf);
	// COLOR = vec4(UV, 0.0, 1.0);
}