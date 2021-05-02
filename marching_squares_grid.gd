tool

extends MeshInstance2D
class_name MarchingSquaresGrid

const MarchingSquaresMeshBuilder := preload("marching_squares_mesh_builder.gd");

export var grid_cells := Vector2(32, 32);

var _builder: MarchingSquaresMeshBuilder;

# Called when the node enters the scene tree for the first time.
func _ready():
	_builder = MarchingSquaresMeshBuilder.new();
	self.mesh = _builder.build_mesh(grid_cells);


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
