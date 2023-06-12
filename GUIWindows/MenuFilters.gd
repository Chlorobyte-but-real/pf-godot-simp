extends MenuDropdown

var tool_manager : Node
onready var border_shader : ShaderMaterial = load("res://Shaders/Border.tres")

func setup() -> void:
	tool_manager = $"../../../../../ImageEditLayer/ToolManager"
	
	events = {
		"Blur (Gaussian)": [ self, "apply_blur_shader", "Blur (Gaussian)", [ load("res://Shaders/BlurGaussianX.tres"), load("res://Shaders/BlurGaussianY.tres") ] ],
		"Border": [ self, "apply_border_shader" ],
		"Custom shader...": [ self, "apply_custom_shader" ],
	}
	for key in events:
		enable_conditions[key] = [ tool_manager, "current_layer_exists" ]


var trol_value : float = -1.0
var type : int = 0
var color := Color(0.0, 0.0, 0.0)
var shader_material : ShaderMaterial = null
func got_float_arg(value: float) -> void:
	trol_value = value
func got_border_arg(radius: float, _type: int, _color: Color) -> void:
	trol_value = radius
	type = _type
	color = _color
func got_shader_arg(mat: ShaderMaterial) -> void:
	shader_material = mat


func apply_blur_shader(window_title: String, shaders: Array) -> void:
	var dialog : WindowDialog = $"../../../../../DialogLayer/BlurShader"
	dialog.window_title = TranslationSystem.get_translated_string(window_title)
	dialog.connect("value_selected", self, "got_float_arg", [], CONNECT_ONESHOT)
	dialog.popup()
	
	while dialog.visible:
		yield(get_tree(), "idle_frame")
	
	if trol_value == -1:
		return
	
	for shader in shaders:
		shader.set_shader_param("radius", trol_value)
	trol_value = -1
	
	tool_manager.apply_shaders(shaders)



func apply_border_shader() -> void:
	var dialog : WindowDialog = $"../../../../../DialogLayer/BorderShader"
	dialog.connect("value_selected", self, "got_border_arg", [], CONNECT_ONESHOT)
	dialog.popup()
	
	while dialog.visible:
		yield(get_tree(), "idle_frame")
	
	if trol_value == -1:
		return
	
	border_shader.set_shader_param("radius", trol_value)
	border_shader.set_shader_param("borderType", [0.0, -1.0, 1.0][type])
	border_shader.set_shader_param("borderColor", color)
	trol_value = -1
	
	tool_manager.apply_shaders([border_shader])



func apply_custom_shader() -> void:
	var dialog : WindowDialog = $"../../../../../DialogLayer/CustomShader"
	dialog.connect("value_selected", self, "got_shader_arg", [], CONNECT_ONESHOT)
	dialog.popup()
	
	while dialog.visible:
		yield(get_tree(), "idle_frame")
	
	if !is_instance_valid(shader_material):
		return
	
	tool_manager.apply_shaders([shader_material])
	shader_material = null
