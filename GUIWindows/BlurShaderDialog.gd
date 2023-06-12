extends WindowDialog

signal value_selected(radius)

onready var radius_lineedit : LineEdit = $"VBoxContainer/Radius/LineEdit"
onready var button : Button = $"Button"

func _ready() -> void:
	button.connect("pressed", self, "button_pressed")
	radius_lineedit.text = Preferences.get_pref("BlurDialog.r")

func _process(_delta) -> void:
	button.disabled = !(radius_lineedit.text.is_valid_integer())

func button_pressed() -> void:
	_process(0)
	if !button.disabled:
		var radius := int(radius_lineedit.text)
		
		Preferences.set_pref("BlurDialog.r", radius_lineedit.text)
		
		emit_signal("value_selected", radius)
		visible = false



func popup(rect := Rect2()) -> void:
	.popup(rect)

