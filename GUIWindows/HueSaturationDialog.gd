extends WindowDialog

signal value_selected(hue, saturation, lightness)

onready var hue_slider : HSlider = $"VBoxContainer/Hue/ValueDegrees"
onready var saturation_slider : HSlider = $"VBoxContainer/Saturation/ValuePercent"
onready var lightness_slider : HSlider = $"VBoxContainer/Lightness/ValuePercent"
onready var button : Button = $"Button"

func _ready() -> void:
	button.connect("pressed", self, "button_pressed")
	hue_slider.value = int(Preferences.get_pref("HueSaturation.h"))
	saturation_slider.value = int(Preferences.get_pref("HueSaturation.s"))
	lightness_slider.value = int(Preferences.get_pref("HueSaturation.l"))

func _process(_delta) -> void:
	button.disabled = false

func button_pressed() -> void:
	_process(0)
	if !button.disabled:
		var hue := int(hue_slider.value)
		var saturation := int(saturation_slider.value)
		var lightness := int(lightness_slider.value)
		
		Preferences.set_pref("HueSaturation.h", str(hue_slider.value))
		Preferences.set_pref("HueSaturation.s", str(saturation_slider.value))
		Preferences.set_pref("HueSaturation.l", str(lightness_slider.value))
		
		emit_signal("value_selected", hue, saturation, lightness)
		visible = false



func popup(rect := Rect2()) -> void:
	.popup(rect)
