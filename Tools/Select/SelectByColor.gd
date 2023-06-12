extends SelectTool


func _tool_properties() -> PoolStringArray:
	var total := ._tool_properties()
	total.append_array(["ColorSimilarityThreshold", "ColorSimilarityType"])
	return total

func _drag_start(pos: Vector2) -> bool:
	var threshold : float = get_tool_property("ColorSimilarityThreshold")
	var type : int = get_tool_property("ColorSimilarityType")
	
	if $"../".current_layer_exists():
		var current_layer : Image = $"../".current_layer
		var current_layer_node : Control = $"../".current_layer_node
		
		var w := int(current_layer.get_size().x)
		var h := int(current_layer.get_size().y)
		
		var fill_mask : Image = Utils.get_filled_image(w, h, Image.FORMAT_RGBA5551, Color(0, 0, 0, 0))
		
		Utils.fill_mask(fill_mask, current_layer, pos, threshold, type)
		
		select(current_layer_node.rect_position, current_layer_node.rect_position + Vector2(w, h), fill_mask)
	
	return true
