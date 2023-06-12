extends Control



func _ready() -> void:
	init_new_image(0, 0, false)

func init_new_image(width: int, height: int, add_bg_layer: bool) -> void:
	for child in get_children():
		child.free()
	
	set_image_size(width, height)
	
	if add_bg_layer:
		create_layer_color(TranslationSystem.get_translated_string("Background"), width, height, Color(1, 1, 1, 1))
	
	init_common_finish()

func init_from_image(image_name: String, image: Image) -> void:
	for child in get_children():
		child.free()
	
	set_image_size(image.get_width(), image.get_height())
	
	create_layer_image(image_name, image)
	
	init_common_finish()

func init_common_finish() -> void:
	$"../".offset = (OS.window_size * $"../../DockedUILayer/SafeArea/DockedUI".get_visible_area_middle() - rect_size * 0.5 * $"../".scale).round()
	UndoLog.clear()


func exists() -> bool:
	return rect_size.x > 0 && rect_size.y > 0


func create_layer_image(layer_name: String, image: Image) -> LayerNode:
	if image.get_format() != Image.FORMAT_RGBA8:
		image = image.duplicate(true)
		image.convert(Image.FORMAT_RGBA8)
	
	var tex := ImageTexture.new()
	tex.create_from_image(image, ImageTexture.FLAG_MIPMAPS)
	
	var layer_node := LayerNode.new()
	layer_node.texture = tex
	layer_node.name = layer_name
	add_child(layer_node)
	UndoLog.record([
		[layer_node, "parent", null, self]
	])
	
	return layer_node

func create_layer_color(layer_name: String, width: int, height: int, color: Color) -> LayerNode:
	var image := Image.new()
	image.create(width, height, false, Image.FORMAT_RGBA8)
	image.fill(color)
	return create_layer_image(layer_name, image)


func set_image_size(width: int, height: int) -> void:
	UndoLog.set_active(width > 0 && height > 0)
	UndoLog.record([
		[self, "rect_size", rect_size, Vector2(width, height)]
	])
	rect_size = Vector2(width, height)


func scale_image(factor: Vector2, interpolate) -> void:
	if !exists(): return
	
	var flip_x : bool = factor.x < 0
	var flip_y : bool = factor.y < 0
	
	var abs_factor := factor.abs()
	
	var new_size : Vector2 = (rect_size * abs_factor).round()
	factor = new_size / rect_size
	
	var undolog_record : Array = [
		[self, "rect_size", rect_size, new_size]
	]
	rect_size = new_size.abs()
	
	for child in get_children():
		if child is LayerNode:
			child.changes_begin()
			
			child.rect_position = (child.rect_position * abs_factor).round()
			var image : Image = child.texture.get_data()
			image.resize(int(round(image.get_width() * abs_factor.x)), int(round(image.get_height() * abs_factor.y)), interpolate)
			if flip_x: image.flip_x()
			if flip_y: image.flip_y()
			child.texture.create_from_image(image, ImageTexture.FLAG_MIPMAPS)
			
			if flip_x:
				child.rect_position.x = rect_size.x - (child.rect_position.x + child.rect_size.x)
			if flip_y:
				child.rect_position.y = rect_size.y - (child.rect_position.y + child.rect_size.y)
			
			undolog_record.append_array([
				[child, "texture", child.last_texture, child.texture],
				[child, "rect_position", child.last_position, child.rect_position]
			])
	
	UndoLog.record(undolog_record)

func scale_image_to(new_size: Vector2, interpolate) -> void:
	scale_image(new_size / rect_size, interpolate)
