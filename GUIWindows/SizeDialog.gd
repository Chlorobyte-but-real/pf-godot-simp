extends WindowDialog

signal value_selected(width, height, interpolate)

onready var width_lineedit : LineEdit = $"VBoxContainer/Width/LineEdit"
onready var height_lineedit : LineEdit = $"VBoxContainer/Height/LineEdit"
onready var interpolation_option : OptionButton = $"VBoxContainer/Interpolation/InterpolationOption"
onready var button : Button = $"Button"

var show_interpolation := true

func _ready() -> void:
	button.connect("pressed", self, "button_pressed")
	width_lineedit.text = Preferences.get_pref("SizeDialog.w")
	height_lineedit.text = Preferences.get_pref("SizeDialog.h")
	interpolation_option.selected = int(Preferences.get_pref("SizeDialog.interpolation"))

func _process(_delta) -> void:
	button.disabled = !(width_lineedit.text.is_valid_integer() && height_lineedit.text.is_valid_integer())

func button_pressed() -> void:
	_process(0)
	if !button.disabled:
		var width := int(width_lineedit.text)
		var height := int(height_lineedit.text)
		var interp : int = interpolation_option.selected
		
		Preferences.set_pref("SizeDialog.w", width_lineedit.text)
		Preferences.set_pref("SizeDialog.h", height_lineedit.text)
		Preferences.set_pref("SizeDialog.interpolation", str(interpolation_option.selected))
		
		emit_signal("value_selected", width, height, interp)
		visible = false



func set_input_text(width: int, height: int) -> void:
	width_lineedit.text = str(width)
	height_lineedit.text = str(height)

func popup(rect := Rect2()) -> void:
	.popup(rect)
	
	$VBoxContainer/Interpolation.visible = show_interpolation
	rect_size.y = 110 if show_interpolation else 80
	
	var image : Control = $"../../ImageEditLayer/ImageDisplay"
	set_input_text(int(image.rect_size.x), int(image.rect_size.y))

