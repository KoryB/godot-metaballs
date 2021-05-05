extends MeshInstance2D
class_name MarchingSquaresGrid

const MarchingSquaresMeshBuilder := preload("marching_squares_mesh_builder.gd");
const MarchingSquaresCircle := preload("marching_squares_circle.gd");

export var grid_cells := Vector2(32, 32);

var circles := Array(); # Of Circle objects

var _builder: MarchingSquaresMeshBuilder;

var _local_cell_size: Vector2;
var _circles_position_radius_squared_image: Image;
var _circles_position_radius_squared_texture: ImageTexture;

var time := 0.0;


func _ready():
	_builder = MarchingSquaresMeshBuilder.new();
	self.mesh = _builder.build_mesh(grid_cells);

	_local_cell_size.x = 1.0 / grid_cells.x;
	_local_cell_size.y = 1.0 / grid_cells.y;

	circles.append(MarchingSquaresCircle.new(Vector2(0.0, 0.0), 0.25));
	circles.append(MarchingSquaresCircle.new(Vector2(0.5, 0.0), 0.125));

	_init_circle_data();


func _init_circle_data():
	_circles_position_radius_squared_image = Image.new();
	_circles_position_radius_squared_image.create(circles.size(), 1, false, Image.FORMAT_RGBAF);
	_circles_position_radius_squared_texture = ImageTexture.new();
	_circles_position_radius_squared_texture.create_from_image(_circles_position_radius_squared_image);

	_sync_circle_data()

	print(_circles_position_radius_squared_image.data);


func _process(delta):
	material.set_shader_param("u_local_cell_size", _local_cell_size);
	material.set_shader_param('u_circles_position_radius_squared', _circles_position_radius_squared_texture);
	material.set_shader_param('u_circle_count', circles.size());

	time += delta;

	circles[0].position += Vector2(1, 1) * delta;
	circles[1].position.y = 0.5*cos(time) + 0.5;

	if circles[0].position.y > 1.0:
		circles[0].position *= 0.0;

	_sync_circle_data();


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
	for index in range(circles.size()):
		var circle: MarchingSquaresCircle = circles[index];
		var pixel := circle.get_pixel()
				
		_circles_position_radius_squared_image.lock();
		_circles_position_radius_squared_image.set_pixel(index, 0, pixel);
		_circles_position_radius_squared_image.unlock();


func get_circle_count() -> int:
	return circles.size();
