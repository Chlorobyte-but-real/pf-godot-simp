extends Node


onready var shader_viewport : Viewport = $ShaderViewport
onready var current_layer_border : NinePatchRect = $"../CurrentLayerBorder"
onready var current_selection_border : TextureRect = $"../CurrentSelectionBorder"
onready var current_layer_node : LayerNode = null

var brush_color_primary := Color(0, 0, 0, 1)
var brush_color_secondary := Color(1, 1, 1, 1)
var swap_pri_sec := false

var processing_shader := false

var last_mouse_pos := Vector2.ZERO
var current_layer : Image = null
var texture_changed := false

var last_frame_n := -1


var current_tool_script_path : String = "res://Tools/Draw/Pencil.gd"
func set_tool_script(path: String) -> void:
	$CurrentTool.set_script(load(path))
	current_tool_script_path = path
	
	$CurrentTool.set_tool_properties()

func _ready() -> void:
	set_tool_script(current_tool_script_path)



func current_layer_exists() -> bool:
	return is_instance_valid(current_layer_node) && current_layer_node.is_inside_tree()

func current_layer_border_align() -> void:
	if current_layer_exists():
		var zoom : Vector2 = $"../".scale
		
		current_layer_border.visible = true
		var bounds : Rect2 = Utils.rotate_boundary(current_layer_node.get_global_rect(), Vector2.ZERO, deg2rad(current_layer_node.rect_rotation))
		current_layer_border.rect_global_position = bounds.position - Vector2(1, 1) / zoom
		current_layer_border.rect_size = bounds.size * zoom + Vector2(2, 2)
		current_layer_border.rect_scale = Vector2(1, 1) / zoom
	else:
		current_layer_border.visible = false

func current_layer_mix_pixel(x: int, y: int, color: Color, interp: float) -> void:
	if x < 0 || y < 0 || x >= current_layer.get_width() || y >= current_layer.get_height():
		return
	if !current_selection_border.can_modify_pixel(x + int(current_layer_node.rect_position.x), y + int(current_layer_node.rect_position.y)):
		return
	
	var current_color := current_layer.get_pixel(x, y)
	if color.a == -1: # undelete
		color.a = 1
		current_color.a = lerp(current_color.a, color.a, interp)
		current_layer.set_pixel(x, y, current_color)
	elif color.a == 0:
		current_color.a = lerp(current_color.a, color.a, interp)
		current_layer.set_pixel(x, y, current_color)
	else:
		current_layer.set_pixel(x, y, current_color.linear_interpolate(color, interp))
	texture_changed = true

func current_layer_mix_pixel_f(x: float, y: float, color: Color, interp: float) -> void:
	current_layer_mix_pixel(int(round(x)), int(round(y)), color, interp)

func current_layer_mix_pixel_primary_brush(x: int, y: int, modulate: Color = Color(1, 1, 1, 1)) -> void:
	var curr_color := brush_color_primary * modulate
	var interp := curr_color.a
	curr_color.a = 1.0
	current_layer_mix_pixel(x, y, curr_color, interp)
func current_layer_mix_pixel_f_primary_brush(x: float, y: float, modulate: Color = Color(1, 1, 1, 1)) -> void:
	var curr_color := brush_color_primary * modulate
	var interp := curr_color.a
	curr_color.a = 1.0
	current_layer_mix_pixel_f(x, y, curr_color, interp)

func current_layer_mix_pixel_secondary_brush(x: int, y: int, modulate: Color = Color(1, 1, 1, 1)) -> void:
	var curr_color := brush_color_secondary * modulate
	var interp := curr_color.a
	curr_color.a = 1.0
	current_layer_mix_pixel(x, y, curr_color, interp)
func current_layer_mix_pixel_f_secondary_brush(x: float, y: float, modulate: Color = Color(1, 1, 1, 1)) -> void:
	var curr_color := brush_color_secondary * modulate
	var interp := curr_color.a
	curr_color.a = 1.0
	current_layer_mix_pixel_f(x, y, curr_color, interp)


func current_layer_get_fill_mask(start_pos: Vector2, color_similarity_threshold: float, color_similarity_mode: int) -> Image:
	var w := int(current_layer_node.rect_size.x)
	var h := int(current_layer_node.rect_size.y)
	
	var image_empty : Image = Utils.get_filled_image(w, h, Image.FORMAT_RGBA5551, Color(0, 0, 0, 0))
	#var image_full := Utils.get_filled_image(w, h, Image.FORMAT_RGBA5551, Color(0, 0, 0, 0))
	
	var selection_mask := Image.new()
	
	var new_mask : Image = Utils.get_filled_image(w, h, Image.FORMAT_RGBA5551, Color(0, 0, 0, 0))
	
	if !current_selection_border.empty_selection:
		selection_mask = current_layer_get_selection_blit_mask()
		
		var inverted_selection_mask : Image = Utils.get_filled_image(w, h, Image.FORMAT_RGBA5551, Color(0, 0, 0, 1))
		inverted_selection_mask.blit_rect_mask(image_empty, selection_mask, Rect2(0, 0, w, h), Vector2.ZERO)
		selection_mask = inverted_selection_mask
		
		new_mask.blit_rect_mask(selection_mask, selection_mask, Rect2(0, 0, w, h), Vector2.ZERO)
	
	Utils.fill_mask(new_mask, current_layer, start_pos, color_similarity_threshold, color_similarity_mode)
	
	if !current_selection_border.empty_selection:
		new_mask.blit_rect_mask(image_empty, selection_mask, Rect2(0, 0, w, h), Vector2.ZERO)
	
	return new_mask

func current_layer_get_selection_blit_mask() -> Image:
	var blit_mask := Image.new()
	blit_mask.create(int(current_layer_node.rect_size.x), int(current_layer_node.rect_size.y), false, Image.FORMAT_RGBA5551)
	blit_mask.fill(Color(0, 0, 0, 0))
	blit_mask.blit_rect(current_selection_border.texture.get_data(),
		Rect2(Vector2.ZERO, current_selection_border.rect_size),
		current_selection_border.rect_position - current_layer_node.rect_position)
	return blit_mask


#var switch_fix_position := Vector2.ZERO
# Drawing (cursor can go over a GUI, but it shouldn't interrupt processing)
func _input(event: InputEvent) -> void:
	match $CurrentTool.tool_type:
		"SELECT":
			if event is InputEventMouseMotion:
				if Input.is_mouse_button_pressed(BUTTON_LEFT):
					if current_layer_exists():
						current_layer = current_layer_node.texture.get_data()
						current_layer.lock()
					
					var new_mouse_pos : Vector2 = (event.global_position / Utils.get_dpi_scale() - $"../".offset) / $"../".scale - Vector2(0.5, 0.5)
					$CurrentTool.drag(last_mouse_pos, new_mouse_pos, last_frame_n != get_tree().get_frame())
					last_frame_n = get_tree().get_frame()
					last_mouse_pos = new_mouse_pos
					if current_layer_exists():
						current_layer.unlock()
						current_layer = null
			return
	
	if !current_layer_exists():
		return
	
	# in these cases, nothing will happen to the texture, so don't load the image for no reason
	if !(event is InputEventMouseMotion):
		return
	if !(Input.is_mouse_button_pressed(BUTTON_LEFT) || Input.is_mouse_button_pressed(BUTTON_RIGHT)):
		return
	if !$CurrentTool.is_dragging:
		return
	
	while processing_shader:
		yield(get_tree(), "idle_frame")
	
	# use texture_changed to load the texture only when necessary
	if !texture_changed:
		current_layer = current_layer_node.texture.get_data()
		current_layer.lock()
	texture_changed = false
	
	if event is InputEventMouseMotion:
		var dragging : bool = Input.is_mouse_button_pressed(BUTTON_LEFT)
		swap_pri_sec = false
		
		if Input.is_mouse_button_pressed(BUTTON_RIGHT) && $CurrentTool.tool_type == "DRAW":
			dragging = true
			
			var tmp = brush_color_primary
			brush_color_primary = brush_color_secondary
			brush_color_secondary = tmp
			swap_pri_sec = true
		
		if dragging:
			var new_mouse_pos : Vector2 = (event.global_position / Utils.get_dpi_scale() - $"../".offset) / $"../".scale - Vector2(0.5, 0.5)
			$CurrentTool.drag(last_mouse_pos, new_mouse_pos, last_frame_n != get_tree().get_frame())
			last_frame_n = get_tree().get_frame()
			last_mouse_pos = new_mouse_pos
		
		if swap_pri_sec:
			var tmp = brush_color_primary
			brush_color_primary = brush_color_secondary
			brush_color_secondary = tmp
			swap_pri_sec = false
	
	if texture_changed:
		current_layer_node.texture.set_data(current_layer)
	else:
		current_layer.unlock()
		current_layer = null

# Starting/ending draw
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.pressed:
		var focus_owner : Control = current_layer_border.get_focus_owner()
		if is_instance_valid(focus_owner):
			focus_owner.release_focus()
	
	match $CurrentTool.tool_type:
		"SELECT":
			if event is InputEventMouseButton:
				last_mouse_pos = (event.global_position / Utils.get_dpi_scale() - $"../".offset) / $"../".scale - Vector2(0.5, 0.5)
				
				if event.button_index == BUTTON_LEFT:
					if current_layer_exists():
						current_layer = current_layer_node.texture.get_data()
						current_layer.lock()
					if event.pressed:
						$CurrentTool.drag_start(last_mouse_pos)
					else:
						$CurrentTool.drag_end(last_mouse_pos)
					if current_layer_exists():
						current_layer.unlock()
						current_layer = null
			return
	
	if !current_layer_exists():
		return
	
	# in these cases, nothing will happen to the texture, so don't load the image for no reason
	if !(event is InputEventMouseButton):
		return
	if event is InputEventMouseButton:
		if !(event.button_index == BUTTON_LEFT || event.button_index == BUTTON_RIGHT):
			return
		if $CurrentTool.is_dragging == event.pressed:
			return
	
	while processing_shader:
		yield(get_tree(), "idle_frame")
	
	current_layer = current_layer_node.texture.get_data()
	current_layer.lock()
	texture_changed = false
	
	if event is InputEventMouseButton:
		last_mouse_pos = (event.global_position / Utils.get_dpi_scale() - $"../".offset) / $"../".scale - current_layer_node.rect_global_position - Vector2(0.5, 0.5)
		
		var button_index : int = event.button_index
		swap_pri_sec = false
		
		if button_index == BUTTON_RIGHT || (button_index == BUTTON_LEFT && Input.is_mouse_button_pressed(BUTTON_RIGHT)):
			if $CurrentTool.tool_type == "DRAW":
				button_index = BUTTON_LEFT
				
				var tmp = brush_color_primary
				brush_color_primary = brush_color_secondary
				brush_color_secondary = tmp
				swap_pri_sec = true
		
		if button_index == BUTTON_LEFT:
			if event.pressed:
				current_layer_node.changes_begin()
				$CurrentTool.drag_start(last_mouse_pos)
			else:
				if $CurrentTool.drag_end(last_mouse_pos):
					current_layer_node.record_changes()
		
		if swap_pri_sec:
			var tmp = brush_color_primary
			brush_color_primary = brush_color_secondary
			brush_color_secondary = tmp
			swap_pri_sec = false
	
	if texture_changed:
		current_layer_node.texture.set_data(current_layer)
	current_layer.unlock()
	current_layer = null
	texture_changed = false



func apply_shaders(shaders: Array) -> void:
	if !current_layer_exists():
		return
	
	while processing_shader:
		yield(get_tree(), "idle_frame")
	
	processing_shader = true
	
	var canvas_layer : CanvasLayer = shader_viewport.get_node("CanvasLayer")
	
	# Clear children, set texture
	for child in canvas_layer.get_children():
		if child.name == "CurrentLayer" and child is TextureRect:
			child.texture = current_layer_node.texture
			child.rect_position = Vector2.ZERO
			child.rect_rotation = 0.0
			child.rect_scale = Vector2.ONE
			child.modulate = Color(1.0, 1.0, 1.0, 1.0)
			child.material = null
		else:
			child.free()
	
	# Add shaders and back buffer copies
	var add_back_buffer_copy := false
	for shader in shaders:
		if shader is ShaderMaterial:
			if add_back_buffer_copy:
				var back_buffer_copy := BackBufferCopy.new()
				back_buffer_copy.copy_mode = BackBufferCopy.COPY_MODE_VIEWPORT
				canvas_layer.add_child(back_buffer_copy)
			add_back_buffer_copy = true
			
			var shader_rect = $ShaderRectTemplate.duplicate()
			shader_rect.visible = true
			shader_rect.material = shader
			canvas_layer.add_child(shader_rect)
	
	shader_viewport.size = current_layer_node.rect_size
	shader_viewport.render_target_clear_mode = Viewport.CLEAR_MODE_ONLY_NEXT_FRAME
	shader_viewport.render_target_update_mode = Viewport.UPDATE_ONCE
	canvas_layer.visible = true
	
	for _i in range(2):
		yield(get_tree(), "idle_frame")
	
	
	current_layer_node.changes_begin()
	
	var rendered_image : Image = shader_viewport.get_texture().get_data()
	rendered_image.convert(Image.FORMAT_RGBA8)
	
	var result : Image = rendered_image
	if !current_selection_border.empty_selection:
		result = current_layer_node.texture.get_data()
		result.blit_rect_mask(rendered_image, current_layer_get_selection_blit_mask(),
			Rect2(Vector2.ZERO, rendered_image.get_size()), Vector2.ZERO)
	
	current_layer_node.texture.set_data(result)
	current_layer_node.record_changes()
	
	processing_shader = false
	canvas_layer.visible = false

func merge_layers(from: LayerNode, to: LayerNode) -> void:
	while processing_shader:
		yield(get_tree(), "idle_frame")
	
	processing_shader = true
	
	var canvas_layer : CanvasLayer = shader_viewport.get_node("CanvasLayer")
	
	var rect_from := Rect2(from.rect_position, from.texture.get_size())
	var rect_to := Rect2(to.rect_position, to.texture.get_size())
	
	var rect_extended := rect_from.merge(rect_to)
	rect_from.position -= rect_extended.position
	rect_to.position -= rect_extended.position
	
	# Clear children, set texture
	for child in canvas_layer.get_children():
		if child.name == "CurrentLayer" and child is TextureRect:
			child.texture = to.texture
			child.rect_position = rect_to.position
			child.rect_rotation = 0.0
			child.rect_scale = Vector2.ONE
			
			var back_buffer_copy := BackBufferCopy.new()
			back_buffer_copy.copy_mode = BackBufferCopy.COPY_MODE_VIEWPORT
			canvas_layer.add_child(back_buffer_copy)
			
			var dupe : TextureRect = child.duplicate(true)
			dupe.texture = from.texture
			dupe.rect_position = rect_from.position
			dupe.material = from.material
			dupe.modulate = from.modulate
			canvas_layer.add_child(dupe)
		else:
			child.free()
	
	shader_viewport.size = rect_extended.size
	shader_viewport.render_target_clear_mode = Viewport.CLEAR_MODE_ONLY_NEXT_FRAME
	shader_viewport.render_target_update_mode = Viewport.UPDATE_ONCE
	canvas_layer.visible = true
	
	for _i in range(2):
		yield(get_tree(), "idle_frame")
	
	
	to.changes_begin()
	
	var rendered_image : Image = shader_viewport.get_texture().get_data()
	rendered_image.convert(Image.FORMAT_RGBA8)
	
	to.texture.create_from_image(rendered_image, ImageTexture.FLAG_MIPMAPS)
	to.rect_position = rect_extended.position
	
	UndoLog.record([
		[from, "parent", from.get_parent(), null],
		[from, "child_index", from.get_index(), 0],
		
		[to, "texture", to.last_texture, to.texture],
		[to, "rect_position", to.last_position, to.rect_position],
	])
	from.get_parent().remove_child(from)
	
	processing_shader = false
	canvas_layer.visible = false
	shader_viewport.size = Vector2.ONE

func apply_transform(to: LayerNode) -> void:
	while processing_shader:
		yield(get_tree(), "idle_frame")
	
	processing_shader = true
	
	var canvas_layer : CanvasLayer = shader_viewport.get_node("CanvasLayer")
	
	var rect_to := Rect2(to.rect_position, to.texture.get_size())
	var rect_extended : Rect2 = Utils.rotate_boundary(rect_to, Vector2.ZERO, deg2rad(to.rect_rotation))
	rect_to.position -= rect_extended.position
	
	# Clear children, set texture
	for child in canvas_layer.get_children():
		if child.name == "CurrentLayer" and child is TextureRect:
			child.texture = to.texture
			child.rect_position = rect_to.position
			child.rect_rotation = to.rect_rotation
			child.modulate = Color(1.0, 1.0, 1.0, 1.0)
		else:
			child.free()
	
	shader_viewport.size = rect_extended.size
	shader_viewport.render_target_clear_mode = Viewport.CLEAR_MODE_ONLY_NEXT_FRAME
	shader_viewport.render_target_update_mode = Viewport.UPDATE_ONCE
	canvas_layer.visible = true
	
	for _i in range(2):
		yield(get_tree(), "idle_frame")
	
	
	var rendered_image : Image = shader_viewport.get_texture().get_data()
	rendered_image.convert(Image.FORMAT_RGBA8)
	
	to.texture.create_from_image(rendered_image, ImageTexture.FLAG_MIPMAPS)
	to.rect_position -= (rect_extended.size - rect_to.size) / 2.0
	to.rect_rotation = 0.0
	to.rect_scale = Vector2.ONE
	
	UndoLog.record([
		[to, "texture", to.last_texture, to.texture],
		[to, "rect_position", to.last_position, to.rect_position],
	])
	
	processing_shader = false
	canvas_layer.visible = false
	shader_viewport.size = Vector2.ONE



func _process(_delta) -> void:
	OS.low_processor_usage_mode = !processing_shader
	current_layer_border_align()
	
	var focus_owner : Control = current_layer_border.get_focus_owner()
	var listening_to_input : bool = !is_instance_valid(focus_owner)
	
	if listening_to_input:
		if Input.is_action_just_pressed("ui_redo"):
			UndoLog.redo()
		elif Input.is_action_just_pressed("ui_undo"):
			UndoLog.undo()
		
		var cutting := false
		if Input.is_action_just_pressed("copy") || Input.is_action_just_pressed("cut"):
			if current_layer_exists():
				if !current_selection_border.empty_selection:
					var _current_layer : Image = current_layer_node.texture.get_data()
					
					var copied_image : Image = Utils.get_filled_image(int(_current_layer.get_size().x), int(_current_layer.get_size().y), _current_layer.get_format(), Color(0, 0, 0, 0))
					
					copied_image.blit_rect_mask(_current_layer,
						current_layer_get_selection_blit_mask(), Rect2(Vector2.ZERO, _current_layer.get_size()), Vector2.ZERO)
					var rect : Rect2 = copied_image.get_used_rect()
					
					if rect.size != _current_layer.get_size():
						var prev : Image = copied_image
						copied_image = Utils.get_filled_image(int(rect.size.x), int(rect.size.y), _current_layer.get_format(), Color(0, 0, 0, 0))
						copied_image.blit_rect(prev, rect, Vector2.ZERO)
					
					Clipboard.copy_image(copied_image, current_layer_node.rect_position + rect.position)
					
					if Input.is_action_just_pressed("cut"):
						cutting = true
		if Input.is_action_just_pressed("paste"):
			var image : Image = Clipboard.get_image()
			var to : Vector2 = Clipboard.get_image_destination()
			
			if to == Vector2(-696969, -696969):
				to = current_layer_node.rect_position if current_layer_exists() else Vector2.ZERO
			
			if is_instance_valid(image):
				var new_layer : LayerNode = $"../ImageDisplay".create_layer_image("Clipboard", image)
				set_deferred("current_layer_node", new_layer)
				new_layer.rect_position = to
		
		if current_layer_exists():
			if Input.is_action_just_pressed("delete") || cutting:
				if !current_selection_border.empty_selection:
					current_layer_node.changes_begin()
					
					var _current_layer : Image = current_layer_node.texture.get_data()
					
					_current_layer.blit_rect_mask(
						Utils.get_filled_image(int(_current_layer.get_size().x), int(_current_layer.get_size().y), _current_layer.get_format(), Color(0, 0, 0, 0)),
						current_layer_get_selection_blit_mask(), Rect2(Vector2.ZERO, _current_layer.get_size()), Vector2.ZERO)
					
					current_layer_node.texture.set_data(_current_layer)
					current_layer_node.record_changes()
				else:
					current_layer_node.remove_layer()
		
		if Input.is_action_just_pressed("select_all"):
			var rect : Rect2 = Rect2(current_layer_node.rect_position, current_layer_node.rect_size) if current_layer_exists() else Rect2(Vector2.ZERO, $"../ImageDisplay".rect_size)
			
			if rect.has_no_area():
				current_selection_border.clear_selection()
			else:
				current_selection_border.set_selection(Utils.get_filled_image(int(rect.size.x), int(rect.size.y), Image.FORMAT_RGBA5551, Color(0, 0, 0, 1)), int(rect.position.x), int(rect.position.y))
