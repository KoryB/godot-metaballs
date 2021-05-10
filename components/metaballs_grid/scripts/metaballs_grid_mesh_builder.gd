extends Reference
class_name MarchingSquaresMeshBuilder

var _surface_tool: SurfaceTool;
var _vertex_count: int;

const square_offsets = [
    Vector2(0, 0),
    Vector2(1, 0),
    Vector2(0, 1),
    Vector2(1, 1),
]

const index_offsets = [0, 1, 2, 2, 3, 1] # clockwise winding


func _init():
    _surface_tool = SurfaceTool.new();
    _vertex_count = 0;


func build_mesh(grid_cells: Vector2, color:Color = Color.white) -> Mesh:
    _initialize_grid(color);
    _build_grid(grid_cells);
    _finalize_grid();

    return _surface_tool.commit();


func _initialize_grid(color: Color):
    _vertex_count = 0;

    _surface_tool.clear();
    _surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES);
    _surface_tool.add_color(color);


func _build_grid(grid_cells: Vector2):
    for x in range(grid_cells.x):
        for y in range(grid_cells.y):
            _build_grid_cell(Vector2(x, y), grid_cells);


func _build_grid_cell(cell_position: Vector2, grid_cells: Vector2):
    _add_grid_cell_indices()
    _add_grid_cell_vertices(cell_position, grid_cells);


func _add_grid_cell_vertices(cell_position: Vector2, grid_cells: Vector2):
    var count = 0;

    for offset in square_offsets:
        var position_normalized = cell_position + offset;
        position_normalized.x /= grid_cells.x;
        position_normalized.y /= grid_cells.y;

        var vertex = Vector3(position_normalized.x, position_normalized.y, 0);

        _surface_tool.add_uv(offset);
        _surface_tool.add_vertex(vertex);

        _vertex_count += 1;



func _add_grid_cell_indices():
    for offset in index_offsets:
        _surface_tool.add_index(_vertex_count + offset)


func _finalize_grid():
    _surface_tool.index();