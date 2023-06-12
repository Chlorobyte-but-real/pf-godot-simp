extends ColorPickerButton

export var property_name : String = "brush_color_primary"

func _ready() -> void:
	color = get_tree().current_scene.get_node("ImageEditLayer/ToolManager").get(property_name)
	$"../".color = color
	get_picker().deferred_mode = true

func _color_changed(color: Color) -> void:
	self.color = color
	$"../".color = color
	get_tree().current_scene.get_node("ImageEditLayer/ToolManager").set(property_name, color)
