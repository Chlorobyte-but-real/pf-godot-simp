extends Tool
class_name DrawTool

var tool_type := "DRAW"


var brush_apply_list := []
func brush_draw(x: float, y: float) -> void:
	brush_apply_list.append([x, y])



func brush_apply(erase: bool) -> void:
	var tool_manager : Node = $"../"
	var current_layer : Image = tool_manager.current_layer
	var current_layer_node_x := int(tool_manager.current_layer_node.rect_position.x)
	var current_layer_node_y := int(tool_manager.current_layer_node.rect_position.y)
	var w : int = tool_manager.current_layer.get_width()
	var h : int = tool_manager.current_layer.get_height()
	
	var radius : float = get_tool_property("BrushRadius")
	#var radius_sqr : float = radius*radius
	
	#var sqrt_force : float = sqrt(get_tool_property("BrushForce"))
	var force : float = get_tool_property("BrushForce")
	
	var brush_apply_dict := {}
	Utils.stamp_brushes(brush_apply_dict, radius, force, brush_apply_list, w, h)
	
# Original:
#	if erase:
#		var _color := Color(0.0, 0.0, 0.0, -1.0 if Input.is_mouse_button_pressed(BUTTON_RIGHT) else 0.0)
#		for key in brush_apply_list:
#			var _x : int = key % w
#			var _y : int = int(key / w)
#			tool_manager.current_layer_mix_pixel(_x, _y, _color, brush_apply_list[key])
#	else:
#		for key in brush_apply_list:
#			var _x : int = key % w
#			var _y : int = int(key / w)
#			tool_manager.current_layer_mix_pixel_primary_brush(_x, _y, Color(1.0, 1.0, 1.0, brush_apply_list[key]))

# Inline optimized:
	if erase:
		var color := Color(0.0, 0.0, 0.0, -1.0 if tool_manager.swap_pri_sec else 0.0)
		for key in brush_apply_dict:
			var _x : int = key % w
			var _y : int = int(key / w)
			
			if tool_manager.current_selection_border.can_modify_pixel(_x + current_layer_node_x, _y + current_layer_node_y):
				var current_color := current_layer.get_pixel(_x, _y)
				if color.a == -1: # undelete
					color.a = 1
					current_color.a = lerp(current_color.a, color.a, brush_apply_dict[key])
					current_layer.set_pixel(_x, _y, current_color)
				else:
					current_color.a = lerp(current_color.a, color.a, brush_apply_dict[key])
					current_layer.set_pixel(_x, _y, current_color)
		
		tool_manager.texture_changed = true
	else:
		var color : Color = tool_manager.brush_color_primary
		for key in brush_apply_dict:
			var _x : int = key % w
			var _y : int = int(key / w)
			
			if tool_manager.current_selection_border.can_modify_pixel(_x + current_layer_node_x, _y + current_layer_node_y):
				var current_color := current_layer.get_pixel(_x, _y)
				current_layer.set_pixel(_x, _y, current_color.linear_interpolate(color, brush_apply_dict[key]))
		
		tool_manager.texture_changed = true
	
	brush_apply_list.clear()
