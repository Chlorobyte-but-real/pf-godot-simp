extends Panel

var reference : LayerNode = null
var last_child_position := 0

onready var style_override : StyleBox = get("custom_styles/panel")

var is_being_dragged := false
var drag_total_position : float = 0

func _ready() -> void:
	$Select.connect("pressed", self, "select_layer")
	$Select.connect("button_down", self, "start_drag")
	$Select.connect("button_up", self, "stop_drag")

func _process(_delta) -> void:
	if is_instance_valid(reference) && reference.is_inside_tree():
		set("custom_styles/panel", style_override if get_tree().current_scene.get_node("ImageEditLayer/ToolManager").current_layer_node == reference else null)
		
		if is_being_dragged:
			while drag_total_position >= rect_size.y:
				drag_total_position -= rect_size.y
				
				if get_index() < get_parent().get_child_count() - 1:
					print("Move down")
					get_parent().move_child(self, get_index() + 1)
					reference.get_parent().move_child(reference, reference.get_index() - 1)
			
			while drag_total_position <= -rect_size.y:
				drag_total_position += rect_size.y
				
				if get_index() > 1:
					print("Move up")
					get_parent().move_child(self, get_index() - 1)
					reference.get_parent().move_child(reference, reference.get_index() + 1)
		else:
			drag_total_position = 0

func start_drag() -> void:
	is_being_dragged = true
	last_child_position = get_index()

func stop_drag() -> void:
	is_being_dragged = false
	
	if last_child_position != get_index():
		UndoLog.record([
			[self, "child_index", last_child_position, get_index()],
			[reference, "child_index", reference.get_index() - last_child_position + get_index(), reference.get_index()],
		])
		
		last_child_position = get_index()

func select_layer() -> void:
	get_tree().current_scene.get_node("ImageEditLayer/ToolManager").current_layer_node = reference


func _input(event) -> void:
	if event is InputEventMouseMotion:
		if is_being_dragged:
			drag_total_position += event.relative.y
