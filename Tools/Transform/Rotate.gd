extends Tool


var tool_type := "TRANSFORM"

var _rotation : float = 0.0

func _drag_start(_pos: Vector2) -> bool:
	_rotation = 0.0
	return true

func _drag(from: Vector2, to: Vector2, _unique_frame: bool) -> bool:
	_rotation += to.x - from.x
	
	$"../".current_layer_node.rect_pivot_offset = $"../".current_layer_node.rect_size / 2.0
	var applied_rotation := _rotation
	if Input.is_key_pressed(KEY_CONTROL):
		applied_rotation = round(applied_rotation / 15.0) * 15.0
	$"../".current_layer_node.rect_rotation = applied_rotation
	return true

func _drag_end(_pos: Vector2) -> bool:
	$"../".apply_transform($"../".current_layer_node)
	return false # do not record changes
