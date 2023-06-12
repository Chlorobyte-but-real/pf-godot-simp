extends Tool


var tool_type := "TRANSFORM"

var _scale := Vector2.ONE

var interpolation_modes := {
	0: Image.INTERPOLATE_NEAREST,
	1: Image.INTERPOLATE_BILINEAR,
	2: Image.INTERPOLATE_CUBIC,
	3: Image.INTERPOLATE_LANCZOS,
}


func _tool_properties() -> PoolStringArray:
	return PoolStringArray(["ScaleInterpolationMode"])


func _drag_start(_pos: Vector2) -> bool:
	_scale = Vector2.ONE
	return true

func _drag(from: Vector2, to: Vector2, _unique_frame: bool) -> bool:
	_scale += (to - from) / $"../".current_layer_node.rect_size
	
	$"../".current_layer_node.rect_pivot_offset = Vector2.ZERO
	
	var applied_scale := _scale
	if Input.is_key_pressed(KEY_CONTROL):
		applied_scale.x = round(applied_scale.x)
		applied_scale.y = round(applied_scale.y)
	if Input.is_key_pressed(KEY_SHIFT):
		if abs(applied_scale.x - 1.0) < abs(applied_scale.y - 1.0):
			applied_scale.x = 1.0
		else:
			applied_scale.y = 1.0
	$"../".current_layer_node.rect_scale = applied_scale
	return true

func _drag_end(_pos: Vector2) -> bool:
	var layer : LayerNode = $"../".current_layer_node
	
	layer.scale_layer(layer.rect_scale, interpolation_modes[get_tool_property("ScaleInterpolationMode")], true)
	layer.rect_scale = Vector2.ONE
	return false # do not record changes
