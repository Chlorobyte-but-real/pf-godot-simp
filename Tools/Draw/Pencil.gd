extends Tool


var tool_type := "DRAW"


func _drag_start(pos: Vector2) -> bool:
	clear_trajectory()
	
	$"../".current_layer_mix_pixel_f_primary_brush(pos.x, pos.y)
	return true

func _drag(from: Vector2, to: Vector2, _unique_frame: bool) -> bool:
	var trajectory := get_trajectory(from, to, 1.0)
	
	for pos in trajectory:
		$"../".current_layer_mix_pixel_f_primary_brush(pos.x, pos.y)
	return true

