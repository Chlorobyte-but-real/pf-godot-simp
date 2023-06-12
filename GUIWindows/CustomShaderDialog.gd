extends WindowDialog

signal value_selected(shader)

onready var code_textedit : TextEdit = $TextEdit
onready var button : Button = $Button
onready var save_button : Button = $HBoxContainer/SaveButton
onready var load_button : Button = $HBoxContainer/LoadButton

var d := Directory.new()
var f := File.new()

func _ready() -> void:
	button.connect("pressed", self, "button_pressed")
	save_button.connect("pressed", self, "save_button_pressed")
	load_button.connect("pressed", self, "load_button_pressed")
	
	$Save.connect("file_selected", self, "_save")
	$Load.connect("file_selected", self, "_load")

func _process(_delta) -> void:
	button.disabled = false

func button_pressed() -> void:
	_process(0)
	if !button.disabled:
		var code : String = code_textedit.text
		
		var shader := Shader.new()
		shader.code = code
		
		var mat := ShaderMaterial.new()
		mat.shader = shader
		
		emit_signal("value_selected", mat)
		visible = false


func get_dialog_path() -> String:
	var path := Preferences.get_pref("ShaderFileDialog.path")
	
	if !d.dir_exists(path):
		path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)+"/"
	
	if !path.ends_with("/"):
		path += "/"
	return path

func save_dialog_path(path: String) -> void:
	path = path.get_base_dir()
	
	Preferences.set_pref("ShaderFileDialog.path", path)

func save_button_pressed() -> void:
	$Save.current_path = get_dialog_path()
	$Save.popup()
	$Save.window_title = TranslationSystem.get_translated_string("Save shader file")

func load_button_pressed() -> void:
	$Load.current_path = get_dialog_path()
	$Load.popup()
	$Load.window_title = TranslationSystem.get_translated_string("Open shader file")

func _save(path: String) -> void:
	save_dialog_path(path)
	
	f.open(path, File.WRITE)
	f.store_string(code_textedit.text)
	f.close()

func _load(path: String) -> void:
	save_dialog_path(path)
	
	f.open(path, File.READ)
	code_textedit.text = f.get_as_text()
	f.close()



func popup(rect := Rect2()) -> void:
	.popup(rect)
