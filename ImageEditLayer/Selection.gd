extends TextureRect


var empty_selection : bool = true

func _process(_delta) -> void:
	material.set_shader_param("uvPerPixel", Vector2(1.0, 1.0) / $"../".scale)




var _image_modified : bool = true
var _last_image_data : PoolByteArray = []
func can_modify_pixel(x: int, y: int) -> bool:
	if empty_selection: return true
	
	x -= int(rect_position.x)
	y -= int(rect_position.y)
	
	if x < 0 || y < 0 || x >= rect_size.x || y >= rect_size.y:
		return false
	
	if _last_image_data.size() == 0 || _image_modified:
		_last_image_data = texture.get_data().get_data()
		_image_modified = false
	
	return (_last_image_data[(x + y * texture.get_width()) * 2] & 1) != 0

func clear_selection() -> void:
	rect_position = Vector2.ZERO
	
	var new_image := Image.new()
	new_image.create(1, 1, false, Image.FORMAT_RGBA5551)
	new_image.fill(Color(0, 0, 0, 0))
	texture.create_from_image(new_image, Texture.FLAG_MIPMAPS)
	
	rect_size = Vector2(1, 1)
	empty_selection = true


func set_selection(image: Image, x: int, y: int) -> void:
	clear_selection()
	add_to_selection(image, x, y)

func add_to_selection(image: Image, x: int, y: int) -> void:
	_apply_to_selection([[image, x, y, Color(0, 0, 0, 1)]])

func subtract_from_selection(image: Image, x: int, y: int) -> void:
	_apply_to_selection([[image, x, y, Color(0, 0, 0, 0)]])

# Each element of the array is an array with 4 elements each:
# image: Image, x: int, y: int, apply_image_fill: Color
# Could this be optimized further?
func _apply_to_selection(applications: Array) -> void:
	_ensure_texture_format()
	var curr_image : Image = texture.get_data()
	
	for application in applications:
		var image : Image = application[0]
		var x : int = application[1]
		var y : int = application[2]
		var apply_image_fill : Color = application[3]
		
		var add_rect := Rect2(Vector2(x, y), image.get_size())
		
		var new_rect : Rect2 = curr_image.get_used_rect()
		new_rect.position += rect_position
		new_rect = _expand_selection_rect(new_rect.merge(add_rect))
		
		var apply_image := Image.new()
		apply_image.create(image.get_width(), image.get_height(), false, Image.FORMAT_RGBA5551)
		apply_image.fill(apply_image_fill)
		
		var new_image := Image.new()
		new_image.create(int(min(new_rect.size.x, 16384)), int(min(new_rect.size.y, 16384)), false, Image.FORMAT_RGBA5551)
		new_image.blit_rect(curr_image, Rect2(Vector2.ZERO, curr_image.get_size()), rect_position - new_rect.position)
		new_image.blit_rect_mask(apply_image, image, Rect2(Vector2.ZERO, image.get_size()), Vector2(x, y) - new_rect.position)
		
		rect_position = new_rect.position
		curr_image = new_image
	
	texture.create_from_image(curr_image, Texture.FLAG_MIPMAPS)
	rect_size = Vector2(1, 1)
	empty_selection = curr_image.is_empty()
	_image_modified = true


func intersect_selection_with(image: Image, x: int, y: int) -> void:
	_ensure_texture_format()
	
	var add_rect := Rect2(Vector2(x, y), image.get_size())
	var curr_image : Image = texture.get_data()
	
	var new_rect : Rect2 = curr_image.get_used_rect()
	new_rect.position += rect_position
	new_rect = _expand_selection_rect(new_rect.clip(add_rect))
	if new_rect.has_no_area():
		clear_selection()
		return
	
	var mask_image := Image.new()
	mask_image.create(image.get_width(), image.get_height(), false, Image.FORMAT_RGBA5551)
	mask_image.blit_rect(curr_image, Rect2(Vector2.ZERO, curr_image.get_size()), rect_position - Vector2(x, y))
	
	var new_image := Image.new()
	new_image.create(int(min(new_rect.size.x, 16384)), int(min(new_rect.size.y, 16384)), false, Image.FORMAT_RGBA5551)
	new_image.blit_rect_mask(mask_image, image, Rect2(Vector2.ZERO, image.get_size()), Vector2(x, y) - new_rect.position)
	
	texture.create_from_image(new_image, Texture.FLAG_MIPMAPS)
	rect_position = new_rect.position
	rect_size = Vector2(1, 1)
	
	empty_selection = new_image.is_empty()
	_image_modified = true


func xor_selection_with(image: Image, x: int, y: int) -> void:
	_ensure_texture_format()
	var curr_image : Image = texture.get_data()
	
	var mask_image := Image.new()
	mask_image.create(image.get_width(), image.get_height(), false, Image.FORMAT_RGBA5551)
	mask_image.blit_rect(curr_image, Rect2(Vector2.ZERO, curr_image.get_size()), rect_position - Vector2(x, y))
	
	var intersect_image := Image.new()
	intersect_image.create(image.get_width(), image.get_height(), false, Image.FORMAT_RGBA5551)
	intersect_image.blit_rect_mask(mask_image, image, Rect2(Vector2.ZERO, image.get_size()), Vector2.ZERO)
	
	_apply_to_selection([[image, x, y, Color(0, 0, 0, 1)],
						[intersect_image, x, y, Color(0, 0, 0, 0)]])



func _ensure_texture_format() -> void:
	if texture.get_format() != Image.FORMAT_RGBA5551:
		print("! converting selection texture to RGBA5551")
		
		var curr_image : Image = texture.get_data()
		if !is_instance_valid(curr_image):
			curr_image = Utils.get_filled_image(1, 1, Image.FORMAT_RGBA5551, Color(0, 0, 0, 0))
		curr_image.convert(Image.FORMAT_RGBA5551)
		texture.create_from_image(curr_image, Texture.FLAG_MIPMAPS)

func _expand_selection_rect(rect: Rect2) -> Rect2:
	var expand_size : Vector2 = (rect.size * 0.5).round()
	if expand_size.x > 256: expand_size.x = 256
	if expand_size.y > 256: expand_size.y = 256
	return rect.grow_individual(expand_size.x, expand_size.y, expand_size.x, expand_size.y)
