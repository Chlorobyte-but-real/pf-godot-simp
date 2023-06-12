extends MenuDropdown

var image_display : Control

func setup() -> void:
	image_display = $"../../../../../ImageEditLayer/ImageDisplay"
	
	events = {
		"Flip (H)": [ image_display, "scale_image", Vector2(-1.0, 1.0) ],
		"Flip (V)": [ image_display, "scale_image", Vector2(1.0, -1.0) ],
		"Resize": [ self, "resize", false ],
		"Resize canvas": [ self, "resize", true ],
	}
	for key in events:
		enable_conditions[key] = [ image_display, "exists" ]



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


func resize(canvas_only: bool) -> void:
	var dialog : WindowDialog = $"../../../../../DialogLayer/Size"
	dialog.window_title = TranslationSystem.get_translated_string("Resize Canvas" if canvas_only else "Resize Image")
	dialog.connect("value_selected", self, "got_size", [], CONNECT_ONESHOT)
	dialog.popup()
	
	while dialog.visible:
		yield(get_tree(), "idle_frame")
	
	if trol_value == Vector2.ZERO:
		return
	
	var new_size : Vector2 = trol_value
	trol_value = Vector2.ZERO
	
	if canvas_only:
		image_display.set_image_size(new_size.x, new_size.y)
	else:
		image_display.scale_image_to(new_size, interpolate)
