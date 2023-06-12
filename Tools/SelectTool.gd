extends Tool
class_name SelectTool

var tool_type := "SELECT"

enum selection_mode { SET = 0, ADD = 1, SUBTRACT = 2, INTERSECT = 3, XOR = 4 }



func _tool_properties() -> PoolStringArray:
	return PoolStringArray(["SelectionMode"])


func select(from: Vector2, to: Vector2, image: Image) -> void:
	var current_selection_border : TextureRect = $"../../CurrentSelectionBorder"
	
	var id = get_tool_property("SelectionMode")
	
	if from == to:
		# Click without moving the cursor; treat as an empty selection
		match id:
			selection_mode.SET:
				current_selection_border.clear_selection()
			selection_mode.ADD:
				pass
			selection_mode.SUBTRACT:
				pass
			selection_mode.INTERSECT:
				current_selection_border.clear_selection()
			selection_mode.XOR:
				pass
	else:
		match id:
			selection_mode.SET:
				current_selection_border.set_selection(image, min(from.x, to.x), min(from.y, to.y))
			selection_mode.ADD:
				current_selection_border.add_to_selection(image, min(from.x, to.x), min(from.y, to.y))
			selection_mode.SUBTRACT:
				current_selection_border.subtract_from_selection(image, min(from.x, to.x), min(from.y, to.y))
			selection_mode.INTERSECT:
				current_selection_border.intersect_selection_with(image, min(from.x, to.x), min(from.y, to.y))
			selection_mode.XOR:
				current_selection_border.xor_selection_with(image, min(from.x, to.x), min(from.y, to.y))
