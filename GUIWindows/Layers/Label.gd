extends Label


func _process(_delta) -> void:
	if is_instance_valid($"../../".reference):
		text = $"../../".reference.name
		
		var line_edit : LineEdit = get_node_or_null("_LineEdit")
		
		if is_instance_valid(line_edit):
			line_edit.visible = get_tree().current_scene.get_node("ImageEditLayer/ToolManager").current_layer_node == $"../../".reference



func _ready() -> void:
	var line_edit : LineEdit = get_node_or_null("_LineEdit")
	
	if !is_instance_valid(line_edit):
		line_edit = LineEdit.new()
		line_edit.name = "_LineEdit"
		add_child(line_edit)
	
	line_edit.modulate.a = 0
	
	line_edit.anchor_left = 0
	line_edit.anchor_right = 1
	line_edit.anchor_top = 0
	line_edit.anchor_bottom = 1
	
	line_edit.margin_left = 0
	line_edit.margin_right = 0
	line_edit.margin_top = 0
	line_edit.margin_bottom = 0
	
	line_edit.connect("focus_entered", self, "set_line_edit_visible", [ true ])
	line_edit.connect("focus_exited", self, "set_line_edit_visible", [ false ])
	line_edit.connect("gui_input", self, "line_edit_gui_input")

func set_line_edit_visible(_visible: bool) -> void:
	var line_edit : LineEdit = get_node_or_null("_LineEdit")
	if is_instance_valid(line_edit):
		if _visible:
			line_edit.modulate.a = 1
			line_edit.text = $"../../".reference.name
			line_edit.caret_position = line_edit.text.length()
		else:
			line_edit.modulate.a = 0
			line_edit.visible = false
			line_edit.visible = true
			$"../../".reference.name = line_edit.text

func line_edit_gui_input(event) -> void:
	var line_edit : LineEdit = get_node_or_null("_LineEdit")
	if is_instance_valid(line_edit):
		if event is InputEventKey && event.scancode == KEY_ENTER && event.pressed:
			set_line_edit_visible(false)
