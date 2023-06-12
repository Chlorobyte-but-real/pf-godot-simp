extends SelectTool


var start_pos := Vector2.ZERO


func get_rectangle_selection_from_to(from: Vector2, to: Vector2) -> Image:
	return Utils.get_filled_image(int(ceil(abs(from.x - to.x)) + 1), int(ceil(abs(from.y - to.y)) + 1), Image.FORMAT_RGBA5551, Color(0, 0, 0, 1))


func _drag_start(pos: Vector2) -> bool:
	start_pos = pos
	
	var tool_preview : Control = $"../../ToolPreview"
	tool_preview.from = pos
	tool_preview.to = pos
	tool_preview.shape = 0
	tool_preview.update()
	
	return true

func _drag(_from: Vector2, to: Vector2, _unique_frame: bool) -> bool:
	var tool_preview : Control = $"../../ToolPreview"
	tool_preview.to = to
	tool_preview.update()
	
	return true

func _drag_end(pos: Vector2) -> bool:
	select(start_pos, pos, get_rectangle_selection_from_to(start_pos, pos))
	
	var tool_preview : Control = $"../../ToolPreview"
	tool_preview.from = pos
	tool_preview.to = pos
	tool_preview.update()
	
	return true

