extends VBoxContainer


func _ready():
	for property in get_children():
		var value = Preferences.get_pref("ToolProperties."+property.name)
		
		var sub_node : Node
		
		if "selected" in property:
			set_property(property.name, int(value))
			property.connect("option_selected", self, "_save_property", [ property.name ])
			continue
		
		sub_node = property.get_node_or_null("Value")
		if is_instance_valid(sub_node) && sub_node is HSlider:
			set_property(property.name, int(value))
			sub_node.connect("value_changed", self, "_save_property", [ property.name ])
			continue
		
		sub_node = property.get_node_or_null("ValuePercent")
		if is_instance_valid(sub_node) && sub_node is HSlider:
			set_property(property.name, int(value) / 100.0)
			sub_node.connect("value_changed", self, "_save_property", [ property.name ])
			continue
		
		sub_node = property.get_node_or_null("OptionButton")
		if is_instance_valid(sub_node) && sub_node is OptionButton:
			set_property(property.name, int(value))
			sub_node.connect("item_selected", self, "_save_property", [ property.name ])
			continue
		
		return null


func get_property(id: String):
	var property : Node = get_node(id)
	var sub_node : Node
	
	if "selected" in property:
		var selected_button : Node = property.selected
		return selected_button.get_index()
	
	sub_node = property.get_node_or_null("Value")
	if is_instance_valid(sub_node) && sub_node is HSlider:
		return sub_node.value
	
	sub_node = property.get_node_or_null("ValuePercent")
	if is_instance_valid(sub_node) && sub_node is HSlider:
		return sub_node.value / 100.0
	
	sub_node = property.get_node_or_null("OptionButton")
	if is_instance_valid(sub_node) && sub_node is OptionButton:
		return sub_node.selected
	
	return null

func set_property(id: String, value) -> void:
	var property : Node = get_node(id)
	var sub_node : Node
	
	if "selected" in property:
		property._select(property.buttons[value])
		return
	
	sub_node = property.get_node_or_null("Value")
	if is_instance_valid(sub_node) && sub_node is HSlider:
		sub_node.value = value
		return
	
	sub_node = property.get_node_or_null("ValuePercent")
	if is_instance_valid(sub_node) && sub_node is HSlider:
		sub_node.value = value * 100.0
		return
	
	sub_node = property.get_node_or_null("OptionButton")
	if is_instance_valid(sub_node) && sub_node is OptionButton:
		sub_node.selected = value
		return


func _save_property(value, id: String) -> void:
	Preferences.set_pref("ToolProperties."+id, str(value))
