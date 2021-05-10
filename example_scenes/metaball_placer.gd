extends Node2D


const MetaballScene: PackedScene = preload("res://components/metaball/metaball.tscn")


var _radius := 16.0;


func _input(event: InputEvent):
	if event is InputEventMouseButton and event.is_pressed():
		match event.button_index:
			BUTTON_WHEEL_UP:
				_radius += 4;
		
			BUTTON_WHEEL_DOWN:
				_radius -= 4;
				_radius = max(4.0, _radius);
		
			BUTTON_LEFT:
				var metaball = MetaballScene.instance();
				
				metaball.position = get_local_mouse_position();
				metaball.radius = _radius;
				
				get_parent().add_child(metaball);


func get_pixel() -> Color:
	var mouse_position = get_local_mouse_position();
	
	return Color(mouse_position.x, mouse_position.y, _radius*_radius, 1.0);
