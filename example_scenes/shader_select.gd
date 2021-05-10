extends ItemList

const MARCHING_SQUARES_MODE_INDEX = 0;
const VERTEX_MODE_INDEX = 1;
const FRAGMENT_MODE_INDEX = 2;

# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("item_selected", self, "_on_item_selected");


func _on_item_selected(index: int):
	var grid: MetaballsGrid = get_parent();
	
	match index:
		MARCHING_SQUARES_MODE_INDEX:
			grid.render_mode = grid.RenderMode.MARCHING_SQUARES;
		
		VERTEX_MODE_INDEX:
			grid.render_mode = grid.RenderMode.VERTEX;
		
		FRAGMENT_MODE_INDEX:
			grid.render_mode = grid.RenderMode.FRAGMENT;
