extends WindowDialog

signal value_selected(brightness, contrast)

onready var brightness_slider : HSlider = $"VBoxContainer/Brightness/ValuePercent"
onready var contrast_slider : HSlider = $"VBoxContainer/Contrast/ValuePercent"
onready var button : Button = $"Button"

func _ready() -> void:
	button.connect("pressed", self, "button_pressed")
	brightness_slider.value = int(Preferences.get_pref("BrightnessContrast.b"))
	contrast_slider.value = int(Preferences.get_pref("BrightnessContrast.c"))

func _process(_delta) -> void:
	button.disabled = false

func button_pressed() -> void:
	_process(0)
	if !button.disabled:
		var brightness := int(brightness_slider.value)
		var contrast := int(contrast_slider.value)
		
		Preferences.set_pref("BrightnessContrast.b", str(brightness_slider.value))
		Preferences.set_pref("BrightnessContrast.c", str(contrast_slider.value))
		
		emit_signal("value_selected", brightness, contrast)
		visible = false



func popup(rect := Rect2()) -> void:
	.popup(rect)
