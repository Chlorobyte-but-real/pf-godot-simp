extends MenuDropdown

var tool_manager : Node
onready var brightness_contrast_shader : ShaderMaterial = load("res://Shaders/BrightnessContrast.tres")
onready var hue_saturation : ShaderMaterial = load("res://Shaders/HueSaturation.tres")

func setup() -> void:
	tool_manager = $"../../../../../ImageEditLayer/ToolManager"
	
	events = {
		"Brightness/Contrast": [ self, "apply_brightness_contrast" ],
		"Hue/Saturation": [ self, "apply_hue_saturation" ],
		
		"Invert": [ tool_manager, "apply_shaders", [load("res://Shaders/Invert.tres")] ],
		"Value Invert": [ tool_manager, "apply_shaders", [load("res://Shaders/InvertValue.tres")] ],
		"Grayscale": [ tool_manager, "apply_shaders", [load("res://Shaders/Grayscale.tres")] ],
	}
	for key in events:
		enable_conditions[key] = [ tool_manager, "current_layer_exists" ]

var trol_value : float = -3313.0
var contrast : int = 0
func got_brightness_contrast_arg(_brightness: int, _contrast: int) -> void:
	trol_value = _brightness
	contrast = _contrast

var saturation : int = 0
var lightness : int = 0
func got_hue_saturation_arg(_brightness: int, _saturation: int, _lightness: int) -> void:
	trol_value = _brightness
	saturation = _saturation
	lightness = _lightness


func apply_brightness_contrast() -> void:
	var dialog : WindowDialog = $"../../../../../DialogLayer/BrightnessContrast"
	dialog.connect("value_selected", self, "got_brightness_contrast_arg", [], CONNECT_ONESHOT)
	dialog.popup()
	
	while dialog.visible:
		yield(get_tree(), "idle_frame")
	
	if trol_value == -3313:
		return
	
	brightness_contrast_shader.set_shader_param("brightness", trol_value / 100.0)
	brightness_contrast_shader.set_shader_param("contrast", contrast / 100.0)
	trol_value = -3313
	
	tool_manager.apply_shaders([brightness_contrast_shader])

func apply_hue_saturation() -> void:
	var dialog : WindowDialog = $"../../../../../DialogLayer/HueSaturation"
	dialog.connect("value_selected", self, "got_hue_saturation_arg", [], CONNECT_ONESHOT)
	dialog.popup()
	
	while dialog.visible:
		yield(get_tree(), "idle_frame")
	
	if trol_value == -3313:
		return
	
	hue_saturation.set_shader_param("hue", trol_value / 360.0)
	hue_saturation.set_shader_param("saturation", saturation / 100.0)
	hue_saturation.set_shader_param("lightness", lightness / 200.0)
	trol_value = -3313
	
	tool_manager.apply_shaders([hue_saturation])
