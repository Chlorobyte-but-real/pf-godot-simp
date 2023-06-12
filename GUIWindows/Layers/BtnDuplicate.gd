extends TextureButton


func _pressed() -> void:
	$"../../".reference.duplicate_layer()
