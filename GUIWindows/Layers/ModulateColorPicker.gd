extends ColorPickerButton

onready var tool_manager : Node = get_tree().current_scene.get_node("ImageEditLayer/ToolManager")

func _process(_delta) -> void:
	disabled = !tool_manager.current_layer_exists()
	
	if !disabled:
		color = tool_manager.current_layer_node.modulate
	$"../".color = color
	
	$"../../".modulate.a = 0.5 if disabled else 1.0

func _color_changed(color: Color) -> void:
	if tool_manager.current_layer_exists():
		tool_manager.current_layer_node.modulate = color


var _modulate_before := Color(0, 0, 0, 0)
func _pressed() -> void:
	if !tool_manager.current_layer_exists():
		get_picker().hide()
		return
	
	_modulate_before = tool_manager.current_layer_node.modulate

func _popup_closed() -> void:
	if tool_manager.current_layer_exists():
		if tool_manager.current_layer_node.modulate != _modulate_before:
			UndoLog.record([
				[tool_manager.current_layer_node, "modulate", _modulate_before, tool_manager.current_layer_node.modulate],
			])
