extends OptionButton

onready var tool_manager : Node = get_tree().current_scene.get_node("ImageEditLayer/ToolManager")

func _ready() -> void:
	connect("item_selected", self, "_item_selected")

func _get_item_text(i: int) -> String:
	return TranslationSystem._original_text[str(get_path()) + "[" + str(i) + "]"]

func _process(_delta) -> void:
	disabled = !tool_manager.current_layer_exists()
	$"../Label".modulate.a = 0.5 if disabled else 1.0
	
	if !disabled:
		var blend_mode : String = tool_manager.current_layer_node.get_blend_mode()
		
		for i in range(get_item_count()):
			if _get_item_text(i) == blend_mode:
				selected = i
				break

func _item_selected(i: int) -> void:
	if tool_manager.current_layer_exists():
		tool_manager.current_layer_node.set_blend_mode(_get_item_text(i))
