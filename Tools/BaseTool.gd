extends Node
class_name Tool



# implemented by the tools
func _drag_start(_pos: Vector2) -> bool:
	return true
func _drag(_from: Vector2, _to: Vector2, _unique_frame: bool) -> bool:
	return true
func _drag_end(_pos: Vector2) -> bool:
	return true
func _tool_properties() -> PoolStringArray:
	return PoolStringArray([])



var is_dragging := false

func drag_start(pos: Vector2) -> bool:
	if is_dragging: return false
	is_dragging = true
	return _drag_start(pos)

func drag(from: Vector2, to: Vector2, unique_frame: bool) -> bool:
	if !is_dragging: return false
	return _drag(from, to, unique_frame)

func drag_end(pos: Vector2) -> bool:
	if !is_dragging: return false
	is_dragging = false
	return _drag_end(pos)


func set_tool_properties() -> void:
	var tool_properties : Node = get_tree().current_scene.get_node("DockedUILayer/SafeArea/DockedUI/ToolProperties/VBoxContainer/ToolProperties")
	
	for child in tool_properties.get_children():
		child.visible = false
	
	for property_name in _tool_properties():
		tool_properties.get_node(property_name).visible = true

func get_tool_property(id: String):
	var tool_properties : Node = get_tree().current_scene.get_node("DockedUILayer/SafeArea/DockedUI/ToolProperties/VBoxContainer/ToolProperties")
	
	return tool_properties.get_property(id)


func get_trajectory(from: Vector2, to: Vector2, move_by: float) -> PoolVector2Array:
	var trajectory : PoolVector2Array = []
	
	var current := from
	while current != to:
		trajectory.append(current)
		current = current.move_toward(to, move_by)
	
	return trajectory

func clear_trajectory() -> void:
	pass
