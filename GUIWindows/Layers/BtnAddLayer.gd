extends TextureButton


func _pressed() -> void:
	var dialog : WindowDialog = get_tree().current_scene.get_node("DialogLayer/NewProjectOrLayer")
	dialog.adding_layer = true
	dialog.popup()
