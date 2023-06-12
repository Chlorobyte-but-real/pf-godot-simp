extends MenuButton
class_name MenuDropdown


var events : Dictionary = {}
var enable_conditions : Dictionary = {}

func setup() -> void:
	pass


func _ready():
	get_popup().connect("id_pressed", self, "_id_pressed")
	connect("about_to_show", self, "_about_to_show")
	
	setup()


func _id_pressed(id: int) -> void:
	var item_text : String = get_popup().get_item_text(id)
	
	if str(get_path()) + "[" + str(id) + "]" in TranslationSystem._original_text:
		item_text = TranslationSystem._original_text[str(get_path()) + "[" + str(id) + "]"]
	
	if item_text in events:
		var event : Array = events[item_text]
		if event.size() == 2:
			event[0].call(event[1])
		else:
			event[0].callv(event[1], event.slice(2, event.size() - 1))

func _about_to_show() -> void:
	for id in range(get_popup().get_item_count()):
		var item_text : String = get_popup().get_item_text(id)
	
		if str(get_path()) + "[" + str(id) + "]" in TranslationSystem._original_text:
			item_text = TranslationSystem._original_text[str(get_path()) + "[" + str(id) + "]"]
		
		if item_text in enable_conditions:
			var function : Array = enable_conditions[item_text]
			get_popup().set_item_disabled(id, !function[0].call(function[1]))
