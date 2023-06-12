extends Tool


var tool_type := "TRANSFORM"


func _drag(from: Vector2, to: Vector2, _unique_frame: bool) -> bool:
	$"../".current_layer_node.rect_position += to - from
	return true

func _drag_end(_pos: Vector2) -> bool:
	$"../".current_layer_node.rect_position = $"../".current_layer_node.rect_position.round()
	return true
