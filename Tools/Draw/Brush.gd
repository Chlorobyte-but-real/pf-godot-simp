extends DrawTool


func _tool_properties() -> PoolStringArray:
	return PoolStringArray(["BrushRadius", "BrushForce"])

func _drag_start(pos: Vector2) -> bool:
	clear_trajectory()
	
	brush_draw(pos.x, pos.y)
	brush_apply(false)
	return true

func _drag(from: Vector2, to: Vector2, unique_frame: bool) -> bool:
	var radius : float = get_tool_property("BrushRadius")
	
	var trajectory := get_trajectory(from, to, sqrt(radius))
	
	for i in range(trajectory.size()):
		brush_draw(trajectory[i].x, trajectory[i].y)
	
	if unique_frame:
		brush_apply(false)
	return true

func _drag_end(_pos: Vector2) -> bool:
	brush_apply(false)
	return true
