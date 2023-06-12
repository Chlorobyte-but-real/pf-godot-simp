extends HBoxContainer


var buttons := []
var selected : Button = null

func _ready():
	for child in get_children():
		if child is Button:
			buttons.append(child)
			child.connect()
			child.connect("pressed", self, "_select", [child])
	
	if buttons.size() > 0:
		selected = buttons[0]
	
	update_modulate()

func _select(btn: Button) -> void:
	selected = btn

func update_modulate() -> void:
	for button in buttons:
		button.modulate = Color(1, 1, 1) if selected == button else Color(0.75, 0.75, 0.75)
