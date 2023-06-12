extends TextureButton

func _pressed() -> void:
	$"../../../../ImageEditLayer".zoom_towards(OS.window_size * 0.5 / Utils.get_dpi_scale(), -1.0)
