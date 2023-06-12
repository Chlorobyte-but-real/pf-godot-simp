extends TextureButton

onready var tool_manager : Node = get_tree().current_scene.get_node("ImageEditLayer/ToolManager")


func _process(_delta) -> void:
	var ref : LayerNode = $"../../".reference
	if is_instance_valid(ref) && ref.is_inside_tree():
		disabled = ref.get_index() == 0
	modulate.a = 0.5 if disabled else 1.0

func _pressed() -> void:
	var ref : LayerNode = $"../../".reference
	
	if is_instance_valid(ref) && ref.is_inside_tree():
		if ref.get_index() > 0:
			tool_manager.merge_layers(ref, ref.get_parent().get_child(ref.get_index() - 1))
