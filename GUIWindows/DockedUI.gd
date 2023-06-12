extends Control


# Returns a Vector2 with 0.0-1.0 coordinates from left-right, top-bottom
# pointing at the middle of the visible area of the screen
func get_visible_area_middle() -> Vector2:
	var rect := Rect2(Vector2.ZERO, OS.window_size)
	
	var end : Vector2 = rect.end
	rect.position.y += rect_position.y
	rect.end = end
	
	for child in get_children():
		if child is Control:
			if child.anchor_left == 0.0 && child.anchor_right == 0.0:
				rect.position.x = max(rect.position.x, child.rect_size.x)
				rect.end = end
			elif child.anchor_left == 1.0 && child.anchor_right == 1.0:
				rect.end.x = min(rect.end.x, OS.window_size.x - child.rect_size.x)
				end = rect.end
	
	print(OS.window_size)
	print(rect)
	print(rect.get_center() / OS.window_size)
	
	return rect.get_center() / Utils.get_dpi_scale() / OS.window_size
