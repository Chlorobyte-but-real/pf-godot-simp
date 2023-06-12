extends TextureButton

onready var tool_manager : Node = get_tree().current_scene.get_node("ImageEditLayer/ToolManager")


func _pressed() -> void:
	if tool_manager.current_layer_exists():
		tool_manager.current_layer_node.remove_layer()

func _process(_delta) -> void:
	disabled = !tool_manager.current_layer_exists()
	modulate.a = 0.5 if disabled else 1.0
