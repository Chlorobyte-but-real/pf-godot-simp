extends TextureRect
class_name LayerNode



func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	last_texture = texture.duplicate(true)
	
	if !has_node("BackBufferCopy"):
		var back_buffer_copy := BackBufferCopy.new()
		back_buffer_copy.copy_mode = BackBufferCopy.COPY_MODE_VIEWPORT
		back_buffer_copy.name = "BackBufferCopy"
		add_child(back_buffer_copy)

# The layer automatically scaled up, but not down 
var _last_size := Vector2.ZERO
func _process(_delta) -> void:
	var current_size : Vector2 = texture.get_size()
	
	if current_size != _last_size:
		_last_size = current_size
		rect_size = current_size

var last_texture : Texture
var last_position : Vector2

func changes_begin() -> void:
	print("changes_begin()")
	last_texture = texture.duplicate(true)
	last_position = rect_position

func record_changes() -> void:
	print("record_changes()")
	UndoLog.record([
		[self, "texture", last_texture, texture],
		[self, "rect_position", last_position, rect_position],
	])


var _blend_mode : String = ""

func set_blend_mode(blend_mode: String) -> void:
	var new_material : ShaderMaterial = null
	
	if blend_mode != "Normal":
		new_material = load("res://Shaders/LayerBlendModes/"+blend_mode+".tres")
	
	UndoLog.record([
		[self, "material", material, new_material],
		[self, "_blend_mode", _blend_mode, blend_mode],
	])
	material = new_material
	_blend_mode = blend_mode

func get_blend_mode() -> String:
	if material == null:
		return "Normal"
	
	if _blend_mode.empty():
		_blend_mode = material.resource_path.trim_prefix("res://Shaders/LayerBlendModes/").trim_suffix(".tres")
	
	return _blend_mode


func remove_layer() -> void:
	if is_inside_tree():
		UndoLog.record([
			[self, "parent", get_parent(), null],
			[self, "child_index", get_index(), 0],
		])
		get_parent().remove_child(self)

func duplicate_layer() -> void:
	if is_inside_tree():
		var dupe : LayerNode = duplicate()
		dupe.texture = texture.duplicate(true)
		
		var parent : Node = get_parent()
		parent.add_child(dupe)
		parent.move_child(dupe, get_index() + 1)
		
		var i := 1
		var new_name := name + " ("+str(i)+")"
		while is_instance_valid(parent.get_node_or_null(new_name)):
			i += 1
			new_name = name + " ("+str(i)+")"
		
		dupe.name = new_name
		
		UndoLog.record([
			[dupe, "parent", null, dupe.get_parent()],
			[dupe, "child_index", 0, dupe.get_index()],
		])


func scale_layer(factor: Vector2, interpolation, anchor_top_left: bool = false) -> void:
	var flip_x : bool = factor.x < 0
	var flip_y : bool = factor.y < 0
	
	var abs_factor := factor.abs()
	
	var new_size : Vector2 = (rect_size * abs_factor).round()
	factor = new_size / rect_size
	
	changes_begin()
	
	var image : Image = texture.get_data()
	image.convert(Image.FORMAT_RGBA8)
	image.resize(int(round(image.get_width() * abs_factor.x)), int(round(image.get_height() * abs_factor.y)), interpolation)
	if flip_x:
		image.flip_x()
		if anchor_top_left:
			rect_position.x -= image.get_width()
	if flip_y:
		image.flip_y()
		if anchor_top_left:
			rect_position.y -= image.get_height()
	texture.create_from_image(image, ImageTexture.FLAG_MIPMAPS)
	
	record_changes()

func scale_layer_to(new_size: Vector2, interpolation, anchor_top_left: bool = false) -> void:
	scale_layer(new_size / rect_size, interpolation, anchor_top_left)


func set_layer_boundary_size(width: int, height: int) -> void:
	changes_begin()
	
	var current_image : Image = texture.get_data()
	current_image.convert(Image.FORMAT_RGBA8) # just in case
	var new_image := Image.new()
	new_image.create(width, height, false, Image.FORMAT_RGBA8)
	new_image.fill(Color(0, 0, 0, 0))
	new_image.blit_rect(current_image, Rect2(0, 0, current_image.get_width(), current_image.get_height()), Vector2(0, 0))
	texture.create_from_image(new_image, ImageTexture.FLAG_MIPMAPS)
	
	UndoLog.record([
		[self, "rect_size", rect_size, Vector2(width, height)],
		[self, "texture", last_texture, texture],
	])
	rect_size = Vector2(width, height)


func set_layer_boundary_to_image() -> void:
	changes_begin()
	
	var width : int = $"../".rect_size.x
	var height : int = $"../".rect_size.y
	
	var current_image : Image = texture.get_data()
	current_image.convert(Image.FORMAT_RGBA8) # just in case
	var new_image : Image = Utils.get_filled_image(width, height, Image.FORMAT_RGBA8, Color(0, 0, 0, 0))
	new_image.blit_rect(current_image, Rect2(0, 0, current_image.get_width(), current_image.get_height()), rect_position)
	texture.create_from_image(new_image, ImageTexture.FLAG_MIPMAPS)
	
	UndoLog.record([
		[self, "rect_size", rect_size, Vector2(width, height)],
		[self, "texture", last_texture, texture],
		[self, "rect_position", rect_position, Vector2(0, 0)],
	])
	rect_size = Vector2(width, height)
	rect_position = Vector2(0, 0)


func crop_layer_boundary_to_content() -> void:
	changes_begin()
	
	var current_image : Image = texture.get_data()
	current_image.convert(Image.FORMAT_RGBA8) # just in case
	
	var used_rect := current_image.get_used_rect()
	var width := int(used_rect.size.x)
	var height := int(used_rect.size.y)
	
	var new_image : Image = Utils.get_filled_image(width, height, Image.FORMAT_RGBA8, Color(0, 0, 0, 0))
	new_image.blit_rect(current_image, used_rect, Vector2.ZERO)
	texture.create_from_image(new_image, ImageTexture.FLAG_MIPMAPS)
	
	UndoLog.record([
		[self, "rect_size", rect_size, Vector2(width, height)],
		[self, "texture", last_texture, texture],
		[self, "rect_position", rect_position, rect_position + used_rect.position],
	])
	rect_size = Vector2(width, height)
	rect_position += used_rect.position
