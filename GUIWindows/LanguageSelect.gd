extends OptionButton

var items_to_lang := {}


func _ready():
	var current_lang : String = Preferences.get_pref("lang")
	for i in range(get_item_count()):
		items_to_lang[i] = get_item_text(i)
		set_item_text(i, "")
		
		if items_to_lang[i] == current_lang:
			selected = i
	connect("item_selected", self, "_item_selected")

func _item_selected(index: int) -> void:
	TranslationSystem.set_lang(items_to_lang[index])
