extends Control


enum { SHAPE_RECT, SHAPE_CIRCLE }

var from := Vector2.ZERO
var to := Vector2.ZERO

var shape := SHAPE_RECT


func _draw() -> void:
	if from.x == to.x || from.y == to.y: return
	
	rect_scale = Vector2.ONE
	
	match shape:
		SHAPE_RECT:
			draw_rect(Rect2(from - rect_position, to - from).abs(), Color(1, 1, 1, 1), false, 1)
		SHAPE_CIRCLE:
			var center_pos := (from + to) * 0.5 - rect_position
			var scale := (to - from).abs() * 0.5
			
			var deg_to_rad : float = PI / 180.0
			
			var pos_prev := center_pos + Vector2(cos(0), sin(0)) * scale
			
			for i in range(0, 360):
				var pos_next := center_pos + Vector2(cos((i + 1) * deg_to_rad), sin((i + 1) * deg_to_rad)) * scale
				
				draw_line(pos_prev, pos_next, Color(1, 1, 1, 1), 1)
				
				pos_prev = pos_next
