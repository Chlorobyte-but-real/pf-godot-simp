extends WindowDialog

onready var width_lineedit : LineEdit = $"VBoxContainer/Width/LineEdit"
onready var height_lineedit : LineEdit = $"VBoxContainer/Height/LineEdit"
onready var add_bglayer_checkbox : CheckBox = $"VBoxContainer/BgLayer/CheckBox"
onready var button : Button = $"Button"

var adding_layer := false

func _ready() -> void:
	button.connect("pressed", self, "button_pressed")
	width_lineedit.text = Preferences.get_pref("NewProjectDialog.w")
	height_lineedit.text = Preferences.get_pref("NewProjectDialog.h")
	add_bglayer_checkbox.pressed = Preferences.get_pref("NewProjectDialog.bglayer") == "1"

func _process(_delta) -> void:
	button.disabled = !(width_lineedit.text.is_valid_integer() && height_lineedit.text.is_valid_integer())

func popup(rect := Rect2(0,0,0,0)) -> void:
	window_title = TranslationSystem.get_translated_string("New layer" if adding_layer else "New project")
	$Button.text = TranslationSystem.get_translated_string("Add layer" if adding_layer else "Create project")
	$VBoxContainer/BgLayer/CheckBox.text = TranslationSystem.get_translated_string("Opaque background" if adding_layer else "Create background layer")
	
	.popup(rect)

func button_pressed() -> void:
	_process(0)
	if !button.disabled:
		var width := int(width_lineedit.text)
		var height := int(height_lineedit.text)
		
		Preferences.set_pref("NewProjectDialog.w", width_lineedit.text)
		Preferences.set_pref("NewProjectDialog.h", height_lineedit.text)
		Preferences.set_pref("NewProjectDialog.bglayer", "1" if add_bglayer_checkbox.pressed else "0")
		
		if adding_layer:
			$"../../ImageEditLayer/ImageDisplay".create_layer_color(TranslationSystem.get_translated_string("New layer"), width, height, Color(1, 1, 1, 1) if add_bglayer_checkbox.pressed else Color(0, 0, 0, 0))
		else:
			$"../../ImageEditLayer/ImageDisplay".init_new_image(width, height, add_bglayer_checkbox.pressed)
		visible = false
