extends Node


var _copied_image : Image = null
var _dest_pos := Vector2(-696969, -696969)


func copy_image(image: Image, dest_pos: Vector2 = Vector2(-696969, -696969)) -> void:
	_copied_image = image.duplicate(true)
	_dest_pos = dest_pos

func get_image() -> Image:
	return _copied_image

func get_image_destination() -> Vector2:
	return _dest_pos
