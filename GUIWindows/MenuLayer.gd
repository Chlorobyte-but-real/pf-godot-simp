extends MenuDropdown

var tool_manager : Node

enum ResizeMode { SCALE, BOUNDARY, TO_IMAGE, TO_CONTENT, FLIP_X, FLIP_Y }

func setup() -> void:
	tool_manager = $"../../../../../ImageEditLayer/ToolManager"
	
	events = {
		"Flip (H)": [ self, "resize", ResizeMode.FLIP_X ],
		"Flip (V)": [ self, "resize", ResizeMode.FLIP_Y ],
		"Resize": [ self, "resize", ResizeMode.SCALE ],
		"Resize layer boundary": [ self, "resize", ResizeMode.BOUNDARY ],
		"Layer boundary to image": [ self, "resize", ResizeMode.TO_IMAGE ],
		"Crop layer to content": [ self, "resize", ResizeMode.TO_CONTENT ],
	}
	for key in events:
		enable_conditions[key] = [ tool_manager, "current_layer_exists" ]



var interpolation_modes := {
	0: Image.INTERPOLATE_NEAREST,
	1: Image.INTERPOLATE_BILINEAR,
	2: Image.INTERPOLATE_CUBIC,
	3: Image.INTERPOLATE_LANCZOS,
}

var trol_value := Vector2.ZERO
var interpolate := Image.INTERPOLATE_NEAREST
func got_size(width: int, height: int, interpolate_mode: int) -> void:
	trol_value = Vector2(width, height)
	interpolate = interpolation_modes[interpolate_mode]


func resize(mode: int) -> void:
	if !tool_manager.current_layer_exists(): return
	var current_layer_node : LayerNode = tool_manager.current_layer_node
	
	# modes for which no dialog is needed
	match mode:
		ResizeMode.TO_IMAGE:
			current_layer_node.set_layer_boundary_to_image()
			return
		ResizeMode.TO_CONTENT:
			current_layer_node.crop_layer_boundary_to_content()
			return
		ResizeMode.FLIP_X:
			current_layer_node.scale_layer(Vector2(-1.0, 1.0), Image.INTERPOLATE_NEAREST)
			return
		ResizeMode.FLIP_Y:
			current_layer_node.scale_layer(Vector2(1.0, -1.0), Image.INTERPOLATE_NEAREST)
			return
	
	var dialog : WindowDialog = $"../../../../../DialogLayer/Size"
	dialog.window_title = TranslationSystem.get_translated_string({
		ResizeMode.SCALE: "Resize Layer",
		ResizeMode.BOUNDARY: "Resize Layer Boundary",
	}[mode])
	dialog.connect("value_selected", self, "got_size", [], CONNECT_ONESHOT)
	dialog.popup()
	dialog.set_input_text(current_layer_node.rect_size.x, current_layer_node.rect_size.y)
	
	while dialog.visible:
		yield(get_tree(), "idle_frame")
	
	if trol_value == Vector2.ZERO:
		return
	
	var new_size : Vector2 = trol_value
	trol_value = Vector2.ZERO
	
	match mode:
		ResizeMode.SCALE:
			current_layer_node.scale_layer_to(new_size, interpolate)
		ResizeMode.BOUNDARY:
			current_layer_node.set_layer_boundary_size(int(new_size.x), int(new_size.y))
