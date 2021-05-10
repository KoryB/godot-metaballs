extends MeshInstance2D
class_name MetaballsGrid

const MetaballsGridMeshBuilder := preload("metaballs_grid_mesh_builder.gd");

const MarchingSquaresModeShaderMaterial := preload("../materials/marching_squares_render_mode_shader_material.tres");
const VertexModeShaderMaterial := preload("../materials/vertex_render_mode_shader_material.tres");
const FragmentModeShaderMaterial := preload("../materials/fragment_render_mode_shader_material.tres");


enum RenderMode { MARCHING_SQUARES, VERTEX_COLORS, FRAGMENT_COLORS };


export var grid_cells := Vector2(32, 32) setget _set_grid_cells;
export var grid_size := Vector2(256, 256) setget _set_grid_size;
export(RenderMode) var render_mode := RenderMode.FRAGMENT_COLORS setget _set_render_mode;

var _builder: MetaballsGridMeshBuilder;
var _is_children_different := false;
var _circles_cached := [];

# Uniforms
var _local_cell_size: Vector2;
var _circle_position_offset := Vector2(0, 0);
var _circle_position_scale := Vector2(0, 0);
var _circle_radius_squared_scale := 0.0;
var _circles_position_radius_squared_image: Image;
var _circles_position_radius_squared_texture: ImageTexture;


func _ready():
	_is_children_different = get_child_count() != 0;

	_init_render_mode();
	_init_circle_data();


func _init_render_mode():
	_builder = MetaballsGridMeshBuilder.new();

	if render_mode == RenderMode.MARCHING_SQUARES:
		mesh = _builder.build_mesh(grid_cells, grid_size);
		_local_cell_size = grid_size / grid_cells;

		material = MarchingSquaresModeShaderMaterial

	elif render_mode == RenderMode.VERTEX_COLORS:
		mesh = _builder.build_mesh(grid_cells, grid_size);
		_local_cell_size = grid_size / grid_cells;

		material = VertexModeShaderMaterial;

	elif render_mode == RenderMode.FRAGMENT_COLORS:
		mesh = _builder.build_mesh(Vector2(1, 1), grid_size);
		_local_cell_size = Vector2(1, 1);

		material = FragmentModeShaderMaterial;


func _init_circle_data():
	var circles = get_circles();

	_circles_position_radius_squared_image = Image.new();
	_circles_position_radius_squared_image.create(circles.size(), 1, false, Image.FORMAT_RGBAF);

	_circles_position_radius_squared_texture = ImageTexture.new();
	_circles_position_radius_squared_texture.create_from_image(_circles_position_radius_squared_image);

	_sync_circle_data()


func _process(_delta):
	material.set_shader_param("u_local_cell_size", _local_cell_size);

	material.set_shader_param("u_circle_position_offset", _circle_position_offset);
	material.set_shader_param("u_circle_position_scale", _circle_position_scale);
	material.set_shader_param("u_circle_radius_squared_scale", _circle_radius_squared_scale);
	material.set_shader_param('u_circles_position_radius_squared', _circles_position_radius_squared_texture);
	material.set_shader_param('u_circle_count', get_circle_count());

	_sync_circle_data();


func get_circles() -> Array:
	if not _is_children_different:
		return _circles_cached;

	_is_children_different = false;
	_circles_cached = []

	for child in get_children():
		if _is_valid_metaball(child):
			_circles_cached.append(child);

	return _circles_cached;


func get_circle_count() -> int:
	return get_circles().size();


func _sync_circle_data():
	var is_resize_needed := _circles_position_radius_squared_image.get_width() != get_circle_count();

	if is_resize_needed:
		_circles_position_radius_squared_image.resize(get_circle_count(), 1);
	
	_blit_circle_data_to_image();
	
	if is_resize_needed:
		_circles_position_radius_squared_texture.create_from_image(_circles_position_radius_squared_image);
	else:
		_circles_position_radius_squared_texture.set_data(_circles_position_radius_squared_image);


func _blit_circle_data_to_image():
	_calculate_circle_transform_uniforms();

	var circles = get_circles();

	for index in range(circles.size()):
		var circle: Metaball = circles[index];
		var pixel := _get_circle_pixel_transformed(circle);
				
		_circles_position_radius_squared_image.lock();
		_circles_position_radius_squared_image.set_pixel(index, 0, pixel);
		_circles_position_radius_squared_image.unlock();


func _set_grid_cells(new_grid_cells: Vector2):
	if not grid_cells.is_equal_approx(new_grid_cells):
		grid_cells = new_grid_cells;
		_init_render_mode();
	

func _set_grid_size(new_grid_size: Vector2):
	if not grid_size.is_equal_approx(new_grid_size):
		grid_size = new_grid_size;
		_init_render_mode();
		

func _set_render_mode(new_render_mode: int):
	if new_render_mode != render_mode:
		render_mode = new_render_mode;
		_init_render_mode();


func _is_valid_metaball(o: Object) -> bool:
	return o.has_method("get_pixel");


func _calculate_circle_transform_uniforms():
	var min_position = Vector2(INF, INF);
	var max_position = Vector2(-INF, -INF);
	var max_radius_squared = 0;

	for circle in get_circles():
		var raw_pixel = circle.get_pixel();
		var pos = Vector2(raw_pixel.r, raw_pixel.g);
		var radius_squared = raw_pixel.b;

		min_position = minv(min_position, pos);
		max_position = maxv(max_position, pos);
		max_radius_squared = max(max_radius_squared, radius_squared);

	_circle_position_offset = min_position;
	_circle_position_scale = max_position - min_position;
	_circle_radius_squared_scale = max_radius_squared;


func _get_circle_pixel_transformed(circle: Object) -> Color:
	var raw_pixel = circle.get_pixel();
	var position = Vector2(raw_pixel.r, raw_pixel.g);
	var radius_squared = raw_pixel.b;

	var transformed_position = (position - _circle_position_offset) / _circle_position_scale;
	var transformed_radius_squared = radius_squared / _circle_radius_squared_scale;

	return Color(transformed_position.x, transformed_position.y, transformed_radius_squared, raw_pixel.a);


# Overrides
func add_child(node: Node, legible_unique_name: bool = false) -> void:
	.add_child(node, legible_unique_name);

	_is_children_different = true;


func remove_child(node: Node) -> void:
	.remove_child(node);

	_is_children_different = true;


# Math
func maxv(v1: Vector2, v2: Vector2) -> Vector2:
	return Vector2(max(v1.x, v2.x), max(v1.y, v2.y));


func minv(v1: Vector2, v2: Vector2) -> Vector2:
	return Vector2(min(v1.x, v2.x), min(v1.y, v2.y));
