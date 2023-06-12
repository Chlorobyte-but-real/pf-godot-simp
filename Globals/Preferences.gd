extends Node


onready var __default_values := {
	"lang": "hu",
	
	"FileDialog.path": OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)+"/",
	"ShaderFileDialog.path": OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)+"/",
	
	"NewProjectDialog.w": "640",
	"NewProjectDialog.h": "480",
	"NewProjectDialog.bglayer": "1",
	
	"SizeDialog.w": "640",
	"SizeDialog.h": "480",
	"SizeDialog.interpolation": "3",
	
	"BlurDialog.r": "3",
	
	"BorderDialog.r": "3",
	"BorderDialog.type": "1",
	"BorderDialog.color": "#000000",
	
	"BrightnessContrast.b": "100",
	"BrightnessContrast.c": "100",
	
	"HueSaturation.h": "0",
	"HueSaturation.s": "0",
	"HueSaturation.l": "0",
	
	"ToolProperties.SelectionMode": "0",
	"ToolProperties.BrushRadius": "1",
	"ToolProperties.BrushForce": "100",
	"ToolProperties.ColorSimilarityThreshold": "10",
	"ToolProperties.ColorSimilarityType": "0",
	"ToolProperties.ScaleInterpolationMode": "3",
}

var saved_values := {}

var autosave_timer : float = 0.0



func _ready() -> void:
	var f := File.new()
	var path := "user://prefs.txt"
	
	if !f.file_exists(path):
		return
	
	f.open(path, f.READ)
	
	while !f.eof_reached():
		var ln : String = f.get_line()
		var ln_spl : Array = ln.split(':', false)
		
		if ln_spl.size() >= 2:
			saved_values[ln_spl[0]] = ln.substr(ln_spl[0].length() + 1)
			print(ln_spl[0], ": ", saved_values[ln_spl[0]])
	
	f.close()

func _process(delta: float) -> void:
	if autosave_timer > 0.0:
		autosave_timer -= delta
		if autosave_timer <= 0.0:
			print("Saving properties")
			
			var f := File.new()
			var path := "user://prefs.txt"
			
			f.open(path, f.WRITE)
			
			for key in saved_values:
				f.store_line(key+":"+str(saved_values[key]))
			
			f.close()

func _notification(type) -> void:
	if type == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		if autosave_timer > 0.0:
			var f := File.new()
			var path := "user://prefs.txt"
			
			f.open(path, f.WRITE)
			
			for key in saved_values:
				f.store_line(key+":"+str(saved_values[key]))
			
			f.close()

func get_pref(property_name: String) -> String:
	if property_name in saved_values:
		return saved_values[property_name]
	
	assert(property_name in __default_values, "No default value for property " + property_name + "!")
	
	return __default_values[property_name]

func set_pref(property_name: String, value: String) -> void:
	if get_pref(property_name) == value: return
	
	print("non-redundant set_pref ", property_name, "=", value, "  queueing autosave")
	saved_values[property_name] = value
	
	autosave_timer = 5.0
