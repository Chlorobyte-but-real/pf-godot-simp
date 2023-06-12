extends LineEdit


var previous_text : String = ""
var previous_caret_position : int = 0

func _process(_delta) -> void:
	if (text.is_valid_integer() && int(text) > 0 && int(text) <= 9999) || text == "":
		previous_text = text
		previous_caret_position = caret_position
	else:
		text = previous_text
		caret_position = previous_caret_position
