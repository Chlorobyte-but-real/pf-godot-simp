extends Control

func _process(_delta) -> void:
	var safe_area : Rect2 = OS.get_window_safe_area()
	var scale : float = Utils.get_dpi_scale()
	
	rect_position = safe_area.position / scale
	rect_size = safe_area.size / scale
