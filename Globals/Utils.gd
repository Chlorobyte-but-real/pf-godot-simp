extends Node


func get_dpi_scale() -> float:
	return max(1.0, floor(OS.get_screen_dpi() / 96.0))

func set_owner_recursive_to(new_owner: Node, node: Node) -> void:
	for child in node.get_children():
		child.owner = new_owner;
		set_owner_recursive_to(new_owner, child);

func load_image_from_file(path: String) -> Image:
	var f := File.new()
	f.open(path, File.READ);
	var buffer : PoolByteArray = f.get_buffer(f.get_len());
	f.close();
	
	var image : Image = null;
	match path.get_extension():
		"png":
			image = Image.new()
			image.load_png_from_buffer(buffer)
		"jpg", "jpeg":
			image = Image.new()
			image.load_jpg_from_buffer(buffer)
		"bmp":
			image = Image.new()
			image.load_bmp_from_buffer(buffer)
		"tga":
			image = Image.new()
			image.load_tga_from_buffer(buffer)
		"webp":
			image = Image.new()
			image.load_webp_from_buffer(buffer)
	
	return image

func get_filled_image(width: int, height: int, format, color: Color) -> Image:
	var image := Image.new()
	image.create(width, height, false, format);
	image.fill(color);
	return image;

func get_circle_filled_image(width: int, height: int, format, color: Color) -> Image:
	if width <= 1 || height <= 1 || (width <= 2 && height <= 2):
		return get_filled_image(width, height, format, color)
	
	var sqrtHalf : float = sqrt(0.5)
	var oneMinusSqrtHalf : float = 1.0 - sqrtHalf;

	var quadrant := Image.new();
	quadrant.create(int(ceil(width / 2.0)), int(ceil(height / 2.0)), false, format)
	
	quadrant.lock()
	var _width_float : float = width - 0.5
	var _height_float : float = height - 0.5
	# top part
	var _x_range = range(floor(quadrant.get_width() * oneMinusSqrtHalf), int(quadrant.get_width()))
	for y in range(ceil(quadrant.get_height() * oneMinusSqrtHalf)):
		var _y : float = y / _height_float - 0.5
		_y = _y * _y - 0.25

		for x in _x_range:
			var _x : float = x / _width_float - 0.5
			quadrant.set_pixel(x, y, color * -sign(_x * _x + _y))
	# left part
	_x_range = range(int(ceil(quadrant.get_width() * oneMinusSqrtHalf)))
	for y in range(floor(quadrant.get_height() * oneMinusSqrtHalf), quadrant.get_height()):
		var _y : float = y / _height_float - 0.5
		_y = _y * _y - 0.25

		for x in _x_range:
			var _x : float = x / _width_float - 0.5
			quadrant.set_pixel(x, y, color * -sign(_x * _x + _y))
	# completely rectangular part
	var w := int(max(1.0, floor(quadrant.get_width() * sqrtHalf)))
	var h := int(max(1.0, floor(quadrant.get_height() * sqrtHalf)))
	quadrant.blit_rect(get_filled_image(w, h, format, color), Rect2(Vector2.ZERO, Vector2(w, h)), quadrant.get_size() - Vector2(w, h))
	quadrant.unlock();
	
	var quadrant_rect := Rect2(Vector2.ZERO, quadrant.get_size())
	
	var image := Image.new()
	image.create(width, height, false, format)
	
	image.blit_rect(quadrant, quadrant_rect, Vector2.ZERO) # top left
	quadrant.flip_x();
	image.blit_rect(quadrant, quadrant_rect, Vector2(floor(width / 2.0), 0.0)) # top right
	quadrant.flip_y();
	image.blit_rect(quadrant, quadrant_rect, Vector2(floor(width / 2.0), floor(height / 2.0))) # bottom right
	quadrant.flip_x();
	image.blit_rect(quadrant, quadrant_rect, Vector2(0.0, floor(height / 2.0))) # bottom left
	
	return image


func rotate_boundary(rect: Rect2, pivot_offset: Vector2, angle: float) -> Rect2:
	var p1 : Vector2 = rect.position;
	var p2 : Vector2 = rect.position + Vector2(rect.size.x, 0);
	var p3 : Vector2 = rect.position + Vector2(0, rect.size.y);
	var p4 : Vector2 = rect.position + rect.size;

	pivot_offset += rect.position;
	
	p1 -= pivot_offset;
	p2 -= pivot_offset;
	p3 -= pivot_offset;
	p4 -= pivot_offset;

	p1 = p1.rotated(angle);
	p2 = p2.rotated(angle);
	p3 = p3.rotated(angle);
	p4 = p4.rotated(angle);

	p1 += pivot_offset;
	p2 += pivot_offset;
	p3 += pivot_offset;
	p4 += pivot_offset;

	var tl := Vector2(min4(p1.x, p2.x, p3.x, p4.x), min4(p1.y, p2.y, p3.y, p4.y));
	var br := Vector2(max4(p1.x, p2.x, p3.x, p4.x), max4(p1.y, p2.y, p3.y, p4.y));
	return Rect2(tl, br - tl)




func stamp_brushes(brushApplyList: Dictionary, brushRadius: float, brushForce: float, applyCoords: Array, w: int, h: int) -> void:
	var radiusSqr : float = brushRadius * brushRadius
	var sqrtForce : float = sqrt(brushForce)

	for arr in applyCoords:
		var x : float = arr[0]
		var y : float = arr[1]

		var minX := int(clamp(round(x) - ceil(brushRadius), 0.0, w))
		var maxX := int(clamp(round(x) + ceil(brushRadius + 1), 0.0, w))
		var minY := int(clamp(round(y) - ceil(brushRadius), 0.0, h))
		var maxY := int(clamp(round(y) + ceil(brushRadius + 1), 0.0, h))

		for _y in range(minY, maxY):
			var _y_pow : float = (y-_y) * (y-_y);
			var _y_offset : int = _y * w;

			for _x in range(minX, maxX):
				var alphaPrecalc : float = (x-_x);
				alphaPrecalc = alphaPrecalc * alphaPrecalc + _y_pow;
				if alphaPrecalc < radiusSqr:
					var alpha : float = (1.0 - pow(alphaPrecalc / radiusSqr, sqrtForce)) * sqrtForce;
					var key : int = _x + _y_offset;
					if key in brushApplyList:
						var from : float = brushApplyList[key]
						brushApplyList[key] = from * (1.0 - alpha) + alpha;
					else:
						brushApplyList[key] = alpha;
				elif _x > x: break




func max2_abs(a: float, b: float) -> float:
	if a < 0: a = -a
	if b < 0: b = -b
	
	if b > a:
		a = b
	return a
func max4_abs(a: float, b: float, c: float, d: float) -> float:
	if a < 0: a = -a
	if b < 0: b = -b
	if c < 0: c = -c
	if d < 0: d = -d

	if b > a:
		a = b
	if c > a:
		a = c
	if d > a:
		a = d
	return a
func min4(a: float, b: float, c: float, d: float) -> float:
	if b < a:
		a = b
	if c < a:
		a = c
	if d < a:
		a = d
	return a
func max4(a: float, b: float, c: float, d: float) -> float:
	if b > a:
		a = b
	if c > a:
		a = c
	if d > a:
		a = d
	return a
