extends HBoxContainer

signal option_selected(n)


var buttons := []
var selected : Control = null

func _ready():
	for child in get_children():
		if child.has_signal("pressed"):
			buttons.append(child)
			child.connect("pressed", self, "_select", [child])
	
	if buttons.size() > 0:
		selected = buttons[0]
	
	update_modulate()

func _select(btn: Control) -> void:
	selected = btn
	update_modulate()
	
	emit_signal("option_selected", btn.get_index())

func update_modulate() -> void:
	for button in buttons:
		button.modulate = Color(1, 1, 1) if selected == button else Color(0.75, 0.75, 0.75)
