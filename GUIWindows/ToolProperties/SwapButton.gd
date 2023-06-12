extends TextureButton


onready var primary_color_picker_button : ColorPickerButton = $"../Primary/ColorPickerButton"
onready var secondary_color_picker_button : ColorPickerButton = $"../Secondary/ColorPickerButton"


func _pressed() -> void:
	var tmp = primary_color_picker_button.color
	primary_color_picker_button._color_changed(secondary_color_picker_button.color)
	secondary_color_picker_button._color_changed(tmp)
