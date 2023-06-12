extends WindowDialog

signal value_selected(radius, type, color)

onready var radius_lineedit : LineEdit = $"VBoxContainer/Radius/LineEdit"
onready var border_type : OptionButton = $"VBoxContainer/Type/BorderType"
onready var border_color : ColorPickerButton = $"VBoxContainer/Color/BorderColor/ColorPickerButton"
onready var button : Button = $"Button"

func _ready() -> void:
	button.connect("pressed", self, "button_pressed")
	radius_lineedit.text = Preferences.get_pref("BorderDialog.r")
	border_type.selected = int(Preferences.get_pref("BorderDialog.type"))
	border_color.color = Color(Preferences.get_pref("BorderDialog.color"))

func _process(_delta) -> void:
	button.disabled = !(radius_lineedit.text.is_valid_integer())

func button_pressed() -> void:
	_process(0)
	if !button.disabled:
		var radius := int(radius_lineedit.text)
		var type : int = border_type.selected
		var color : Color = border_color.color
		
		Preferences.set_pref("BorderDialog.r", radius_lineedit.text)
		Preferences.set_pref("BorderDialog.type", str(border_type.selected))
		Preferences.set_pref("BorderDialog.color", border_color.color.to_html(false))
		
		emit_signal("value_selected", radius, type, color)
		visible = false



func popup(rect := Rect2()) -> void:
	.popup(rect)

