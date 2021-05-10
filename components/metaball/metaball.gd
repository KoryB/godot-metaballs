extends Node2D
class_name Metaball

export var radius := 0.0 setget set_radius, get_radius;


func _init(new_position = Vector2(0, 0), new_radius = 0.0):
	set_position(new_position);
	set_radius(new_radius);


func set_radius(new_radius: float):
	radius = new_radius;


func get_radius() -> float:
	return radius;


func get_pixel() -> Color:
	return Color(position.x, position.y, radius*radius);
