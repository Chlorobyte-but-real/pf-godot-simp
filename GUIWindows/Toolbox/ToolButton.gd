extends TextureButton

export var tool_script_path := ""
onready var tool_manager : Node = get_tree().current_scene.get_node("ImageEditLayer/ToolManager")

func _pressed() -> void:
	tool_manager.set_tool_script(tool_script_path)

func _process(_delta) -> void:
	modulate.a = 1.0 if tool_manager.current_tool_script_path == tool_script_path else 0.75
