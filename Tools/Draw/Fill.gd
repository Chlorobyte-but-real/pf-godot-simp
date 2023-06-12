extends DrawTool


func _tool_properties() -> PoolStringArray:
	return PoolStringArray(["ColorSimilarityThreshold", "ColorSimilarityType"])

func _drag_start(pos: Vector2) -> bool:
	var threshold : float = get_tool_property("ColorSimilarityThreshold")
	var type : int = get_tool_property("ColorSimilarityType")
	
	var current_layer : Image = $"../".current_layer
	var fill_mask : Image = $"../".current_layer_get_fill_mask(pos, threshold, type)
	
	var apply_image := Image.new()
	apply_image.create(current_layer.get_width(), current_layer.get_height(), false, Image.FORMAT_RGBA8)
	apply_image.fill($"../".brush_color_primary)
	
	current_layer.blit_rect_mask(apply_image, fill_mask, Rect2(0, 0, current_layer.get_width(), current_layer.get_height()), Vector2.ZERO)
	$"../".texture_changed = true
	
	return true
