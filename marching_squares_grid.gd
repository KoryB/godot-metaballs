tool

extends MeshInstance2D
class_name MarchingSquaresGrid

const MarchingSquaresMeshBuilder := preload("marching_squares_mesh_builder.gd");

export var grid_cells := Vector2(32, 32);

var _builder: MarchingSquaresMeshBuilder;
var _local_cell_size: Vector2;

# Called when the node enters the scene tree for the first time.
func _ready():
	_builder = MarchingSquaresMeshBuilder.new();
	self.mesh = _builder.build_mesh(grid_cells);

	_local_cell_size.x = 1.0 / grid_cells.x;
	_local_cell_size.y = 1.0 / grid_cells.y;

	print(_local_cell_size);


func _process(_delta):
	material.set_shader_param("u_local_cell_size", _local_cell_size);
