extends CanvasLayer


var d := Directory.new()
var f := File.new()

func _ready() -> void:
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_DISABLED, SceneTree.STRETCH_ASPECT_IGNORE, Vector2.ZERO, Utils.get_dpi_scale())
	
	$"../DialogLayer/Load".connect("file_selected", self, "_load")
	$"../DialogLayer/Save".connect("file_selected", self, "_save")
	$"../DialogLayer/Import".connect("file_selected", self, "_import")
	$"../DialogLayer/Export".connect("file_selected", self, "_export")
	
	for child in $"../DialogLayer".get_children():
		if child is Popup:
			child.popup_exclusive = true
	
	VisualServer.set_default_clear_color(Color(0x25 / 255.0, 0x25 / 255.0, 0x2a / 255.0, 1.0))
	Input.use_accumulated_input = false



# prevent floating point errors from adding up 
var zoom_level : float = 0.0
func zoom_towards(screen_position: Vector2, factor: float) -> void:
	var current_pos = transform.xform_inv(screen_position)
	var old_scale := scale
	
	zoom_level = clamp(zoom_level + factor, -25, 30)
	scale = Vector2(pow(2.0, zoom_level / 5), pow(2.0, zoom_level / 5))
	
	var new_pos = transform.xform_inv(screen_position)
	offset = (offset - (new_pos - current_pos) / old_scale).round()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == BUTTON_WHEEL_UP:
				zoom_towards(event.position, 1.0)
			elif event.button_index == BUTTON_WHEEL_DOWN:
				zoom_towards(event.position, -1.0)

var last_touched := -400
func _input(event: InputEvent) -> void:
	if event is InputEventMagnifyGesture:
		zoom_towards(event.position, event.factor)
	if event is InputEventScreenTouch:
		if event.pressed:
			if OS.get_ticks_msec() - last_touched < 400:
				var double_click := InputEventMouseButton.new()
				double_click.button_index = BUTTON_LEFT
				double_click.button_mask = BUTTON_LEFT
				double_click.position = event.position
				double_click.global_position = event.position
				double_click.pressed = true
				double_click.doubleclick = true
				Input.parse_input_event(double_click)
				
				last_touched = -400
			else:
				last_touched = OS.get_ticks_msec()

onready var previous_window_size = OS.window_size
func _process(_delta) -> void:
	var current_window_size = OS.window_size
	var prev_offset = offset
	offset = (offset + (current_window_size - previous_window_size) * 0.5).round()
	if offset != prev_offset:
		previous_window_size = current_window_size



func get_dialog_path() -> String:
	var path := Preferences.get_pref("FileDialog.path")
	
	if !d.dir_exists(path):
		path = OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)+"/"
	
	if !path.ends_with("/"):
		path += "/"
	return path

func save_dialog_path(path: String) -> void:
	path = path.get_base_dir()
	
	Preferences.set_pref("FileDialog.path", path)


func new_open_dialog() -> void:
	$"../DialogLayer/NewProjectOrLayer".adding_layer = false
	$"../DialogLayer/NewProjectOrLayer".popup()

func load_open_dialog() -> void:
	$"../DialogLayer/Load".current_path = get_dialog_path()
	$"../DialogLayer/Load".popup()
	$"../DialogLayer/Load".window_title = TranslationSystem.get_translated_string("Open...")

func save_open_dialog() -> void:
	$"../DialogLayer/Save".current_path = get_dialog_path()
	$"../DialogLayer/Save".popup()

func import_open_dialog() -> void:
	$"../DialogLayer/Import".current_path = get_dialog_path()
	$"../DialogLayer/Import".popup()
	$"../DialogLayer/Import".window_title = TranslationSystem.get_translated_string("Import image to layer")

func export_open_dialog() -> void:
	$"../DialogLayer/Export".current_path = get_dialog_path()
	$"../DialogLayer/Export".popup()



func _load(path: String) -> void:
	save_dialog_path($"../DialogLayer/Load".current_path)
	
	match path.get_extension():
		"simp":
			# read compressed data
			f.open_compressed(path, File.READ, File.COMPRESSION_DEFLATE)
			var buffer : PoolByteArray = f.get_buffer(f.get_len())
			f.close()
			# and store it in a temporary .scn for ResourceLoader
			var temporary_scn_file := "user://tmp"+str(OS.get_ticks_usec())+".scn"
			f.open(temporary_scn_file, File.WRITE)
			f.store_buffer(buffer)
			f.close()
			
			var resource : PackedScene = ResourceLoader.load(temporary_scn_file)
			d.remove(temporary_scn_file)
			
			if !is_instance_valid(resource):
				print("Halál macskakaja")
				return
			
			var instance : Node = resource.instance()
			if !load_verify(instance):
				print("Halál macskakaja")
				return
			for child in $ImageDisplay.get_children():
				child.free()
			for child in instance.get_children():
				instance.remove_child(child) # :(
				$ImageDisplay.add_child(child)
			$ImageDisplay.set_image_size(instance.rect_size.x, instance.rect_size.y)
			$ImageDisplay.init_common_finish()
		_:
			var image : Image = Utils.load_image_from_file(path)
			
			if is_instance_valid(image):
				$ImageDisplay.init_from_image(path.get_basename().get_file(), image)

func load_verify(image_display: Node) -> bool:
	if !(image_display is Control): return false
	
	for child in image_display.get_children():
		if !(child is LayerNode):
			child.free()
			continue
		
		var image : Image = child.texture.get_data()
		image.convert(Image.FORMAT_RGBA8)
		child.texture.create_from_image(image, ImageTexture.FLAG_MIPMAPS)
		
		for _child in child.get_children():
			_child.free()
	
	return true



func _save(path: String) -> void:
	save_dialog_path($"../DialogLayer/Save".current_path)
	
	var packed_scene = PackedScene.new()
	Utils.set_owner_recursive_to($ImageDisplay, $ImageDisplay)
	packed_scene.pack($ImageDisplay)
	
	# ResourceLoader assumes data based on file extension so save to a temporary file
	var temporary_scn_file := "user://tmp"+str(OS.get_ticks_usec())+".scn"
	ResourceSaver.save(temporary_scn_file, packed_scene)
	# then take the data
	f.open(temporary_scn_file, File.READ)
	var buffer : PoolByteArray = f.get_buffer(f.get_len())
	f.close()
	# and store it at path, compressed
	# COMPRESSION_DEFLATE has the best compression
	f.open_compressed(path, File.WRITE, File.COMPRESSION_DEFLATE)
	f.store_buffer(buffer)
	f.close()
	d.remove(temporary_scn_file)



func _import(path: String) -> void:
	save_dialog_path($"../DialogLayer/Import".current_path)
	
	var image : Image = Utils.load_image_from_file(path)
	
	if is_instance_valid(image):
		$ImageDisplay.create_layer_image(path.get_basename().get_file(), image)



func _export(path: String) -> void:
	save_dialog_path($"../DialogLayer/Export".current_path)
	
	var export_render_viewport : Viewport = $"../DialogLayer/Export/ExportRenderViewport"
	
	for child in export_render_viewport.get_node("CanvasLayer").get_children():
		child.free()
	for child in $ImageDisplay.get_children():
		var dupe : Node = child.duplicate()
		export_render_viewport.get_node("CanvasLayer").add_child(dupe)
		
		var selection_border : Node = dupe.get_node_or_null("SelectionBorder")
		if is_instance_valid(selection_border):
			selection_border.free()
	
	export_render_viewport.size = $ImageDisplay.rect_size
	export_render_viewport.render_target_clear_mode = Viewport.CLEAR_MODE_ONLY_NEXT_FRAME
	export_render_viewport.render_target_update_mode = Viewport.UPDATE_ONCE
	for _i in range(2):
		OS.low_processor_usage_mode = false
		yield(get_tree(), "idle_frame")
		OS.low_processor_usage_mode = false
	
	var image : Image = export_render_viewport.get_texture().get_data()
	image.convert(Image.FORMAT_RGBA8)
	image.save_png(path)
