extends TextureButton


func set_icon(icon_name: String) -> void:
	var tex : Texture = IconAssets.icons[icon_name]
	texture_normal = tex
	texture_pressed = tex
	texture_hover = tex
	texture_disabled = tex
	texture_focused = tex


var hover := false

func _mouse_entered() -> void:
	hover = true

func _mouse_exited() -> void:
	hover = false

func _pressed() -> void:
	var reference : Node = $"../../../../".reference
	
	reference.visible = !reference.visible
	UndoLog.record([
		[reference, "visible", !reference.visible, reference.visible]
	])

func _process(_delta) -> void:
	var reference : Node = $"../../../../".reference
	
	if is_instance_valid(reference):
		if !reference.is_inside_tree():
			$"../../../../".queue_free()
			return
		
		if !reference.visible:
			modulate.a = 0.5
		else:
			modulate.a = 0.0 if !hover else 1.0
		set_icon("visible_on" if reference.visible else "visible_off")
	else:
		if reference == null:
			$"../../../../".visible = false # hide the template
		else:
			# just disappeared... without any explanation? alright.
			print("just gone?")
			$"../../../../".queue_free()
			return
