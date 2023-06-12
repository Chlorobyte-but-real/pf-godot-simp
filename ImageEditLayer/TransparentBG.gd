extends TextureRect


func _process(_delta) -> void:
	rect_size = $"../ImageDisplay".rect_size * $"../".scale
	rect_scale = Vector2(1.0, 1.0) / $"../".scale
