tool
extends MeshInstance2D
class_name MetaballsGrid

const MetaballsGridMeshBuilder := preload("metaballs_grid_mesh_builder.gd");

const MarchingSquaresModeShaderMaterial := preload("../materials/marching_squares_render_mode_shader_material.tres");
const VertexModeShaderMaterial := preload("../materials/vertex_render_mode_shader_material.tres");
const FragmentModeShaderMaterial := preload("../materials/fragment_render_mode_shader_material.tres");


enum RenderMode { MARCHING_SQUARES, VERTEX_COLORS, FRAGMENT_COLORS };


export var grid_cells := Vector2(32, 32);
export(RenderMode) var render_mode := RenderMode.FRAGMENT_COLORS setget _set_render_mode;


var _builder: MetaballsGridMeshBuilder;
var _is_children_different := false;
var _circles_cached := [];

# Uniforms
var _local_cell_size: Vector2;
var _circles_position_radius_squared_image: Image;
var _circles_position_radius_squared_texture: ImageTexture;


func _ready():
	_is_children_different = get_child_count() != 0;

	_init_render_mode();
	_init_circle_data();


func _init_render_mode():
	_builder = MetaballsGridMeshBuilder.new();

	if render_mode == RenderMode.MARCHING_SQUARES:
		mesh = _builder.build_mesh(grid_cells);

		_local_cell_size.x = 1.0 / grid_cells.x;
		_local_cell_size.y = 1.0 / grid_cells.y;

		material = MarchingSquaresModeShaderMaterial

	elif render_mode == RenderMode.VERTEX_COLORS:
		mesh = _builder.build_mesh(grid_cells);

		_local_cell_size.x = 1.0 / grid_cells.x;
		_local_cell_size.y = 1.0 / grid_cells.y;

		material = VertexModeShaderMaterial;

	elif render_mode == RenderMode.FRAGMENT_COLORS:
		mesh = _builder.build_mesh(Vector2(1, 1));

		_local_cell_size.x = 1.0;
		_local_cell_size.y = 1.0;

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
	var circles = get_circles();

	for index in range(circles.size()):
		var circle: Metaball = circles[index];
		var pixel := circle.get_pixel()
		print(pixel);
				
		_circles_position_radius_squared_image.lock();
		_circles_position_radius_squared_image.set_pixel(index, 0, pixel);
		_circles_position_radius_squared_image.unlock();


func _set_render_mode(new_render_mode: int):
	if new_render_mode != render_mode:
		render_mode = new_render_mode;
		_init_render_mode();


func _is_valid_metaball(o: Object) -> bool:
	return o.has_method("get_pixel");


# Overrides
func add_child(node: Node, legible_unique_name: bool = false) -> void:
	.add_child(node, legible_unique_name);

	_is_children_different = true;


func remove_child(node: Node) -> void:
	.remove_child(node);

	_is_children_different = true;
