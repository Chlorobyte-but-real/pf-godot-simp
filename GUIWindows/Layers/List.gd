extends VBoxContainer



func _get_node_for_wrapped(layer: Node) -> Node:
	for child in get_children():
		if child.reference == layer:
			return child
	
	var node = $LayerTemplate.duplicate()
	add_child(node)
	move_child(node, get_child_count() - 1 - layer.get_index())
	
	node.reference = layer
	node.visible = true
	
	return node

func get_node_for(layer: Node) -> Node:
	var ret_value : Node = _get_node_for_wrapped(layer)
	return ret_value

func _process(_delta) -> void:
	for node in get_tree().current_scene.get_node("ImageEditLayer/ImageDisplay").get_children():
		var layer : Node = get_node_for(node)
		layer.get_node("Left/PreviewBG/Preview").texture = node.texture
