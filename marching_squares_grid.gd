tool

extends MeshInstance2D
class_name MarchingSquaresGrid

const MarchingSquaresMeshBuilder := preload("marching_squares_mesh_builder.gd");
const MarchingSquaresCircle := preload("marching_squares_circle.gd");

export var grid_cells := Vector2(32, 32);
export var circles := Array(); # Of Circle objects

var _builder: MarchingSquaresMeshBuilder;

var _local_cell_size: Vector2;
var _circles_position_radius_squared_image: Image;
var _circles_position_radius_squared_texture: ImageTexture;

# Called when the node enters the scene tree for the first time.
func _ready():
	_builder = MarchingSquaresMeshBuilder.new();
	self.mesh = _builder.build_mesh(grid_cells);

	_local_cell_size.x = 1.0 / grid_cells.x;
	_local_cell_size.y = 1.0 / grid_cells.y;

	circles.append(MarchingSquaresCircle.new(Vector2(0.5, 0.5), 0.5));

	_init_circle_data();


func _init_circle_data():
	_circles_position_radius_squared_image = Image.new();
	_circles_position_radius_squared_texture = ImageTexture.new();
	_circles_position_radius_squared_texture.create_from_image(_circles_position_radius_squared_image);

	_sync_circle_data()


func _process(_delta):
	material.set_shader_param("u_local_cell_size", _local_cell_size);


func _sync_circle_data():
	var is_resize_needed := _circles_position_radius_squared_image.get_width() != get_circle_count();

	if is_resize_needed:
		_circles_position_radius_squared_image.resize(get_circle_count(), 1);
	
	_blit_circle_data_to_image();
	print(_circles_position_radius_squared_image.get_pixel(0, 0));
	
	if is_resize_needed:
		_circles_position_radius_squared_texture.create_from_image(_circles_position_radius_squared_image);
	else:
		_circles_position_radius_squared_texture.set_data(_circles_position_radius_squared_image);

	print(_circles_position_radius_squared_image.get_pixel(0, 0));


func _blit_circle_data_to_image():
	print(circles.size())
	for index in range(circles.size()):
		var circle: MarchingSquaresCircle = circles[index];

		print(index, circle.get_pixel());
		_circles_position_radius_squared_image.lock();
		_circles_position_radius_squared_image.set_pixel(index, 0, circle.get_pixel());
		_circles_position_radius_squared_image.unlock();
		
		print(_circles_position_radius_squared_image.get_pixel(0, 0));



func get_circle_count() -> int:
	return circles.size();
