extends Node


var _undo_log := []
var index := 0
var _active := false


func clear() -> void:
	_undo_log.clear()
	index = 0

func set_active(active: bool) -> void:
	_active = active
	
	if !_active:
		clear()

func record(changes: Array) -> void:
	if !_active: return
	
	# Saving textures directly will eat VRAM, extract the data instead to eat only RAM
	for change in changes:
		var value = change[2]
		if value is Texture:
			change[2] = ["TEXTURE", value.get_data()]
		
		value = change[3]
		if value is Texture:
			change[3] = ["TEXTURE", value.get_data()]
	
	_undo_log.resize(index)
	_undo_log.append(changes)
	index = _undo_log.size()
	print("Recorded change; new length ", index)


func can_undo() -> bool:
	return _active && index > 0

func undo() -> void:
	if can_undo():
		index -= 1
		
		for array in _undo_log[index]:
			var node : Node = array[0]
			var property : String = array[1]
			var value = array[2]
			
			if property == "parent":
				if is_instance_valid(node.get_parent()):
					node.get_parent().remove_child(node)
				
				if is_instance_valid(value) && value is Node:
					value.add_child(node)
				
			elif property == "child_index":
				if is_instance_valid(node.get_parent()):
					node.get_parent().move_child(node, value)
			elif value is Array && value[0] == "TEXTURE":
				node[property].create_from_image(value[1], ImageTexture.FLAG_MIPMAPS)
			else:
				if value is Resource:
					# prevent accidental writing to the undolog
					value = value.duplicate(true)
				
				node.set(property, value)
		
		print("Undo complete of index ", index)


func can_redo() -> bool:
	return _active && index < _undo_log.size()

func redo() -> void:
	if can_redo():
		for array in _undo_log[index]:
			var node : Node = array[0]
			var property : String = array[1]
			var value = array[3]
			
			if property == "parent":
				if is_instance_valid(node.get_parent()):
					node.get_parent().remove_child(node)
				
				if is_instance_valid(value):
					value.add_child(node)
				
			elif property == "child_index":
				if is_instance_valid(node.get_parent()):
					node.get_parent().move_child(node, value)
			elif value is Array && value[0] == "TEXTURE":
				node[property].create_from_image(value[1], ImageTexture.FLAG_MIPMAPS)
			else:
				if value is Resource:
					# prevent accidental writing to the undolog
					value = value.duplicate(true)
				
				node.set(property, value)
		
		print("Redo complete of index ", index)
		index += 1
