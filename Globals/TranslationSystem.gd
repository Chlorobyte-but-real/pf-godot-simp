extends Node


enum CAPITALIZATION_TYPE { KEEP, NEUTRAL, UPPERCASE }

var current_lang_map := {}
var is_default := false

func load_lang_map(path: String) -> void:
	current_lang_map.clear()
	is_default = false
	
	var f := File.new()
	
	if path.ends_with("def.tres"):
		is_default = true
		return
	if !f.file_exists(path):
		print("Language file not found! ", path)
		return
	
	f.open(path, f.READ)
	
	while !f.eof_reached():
		var ln : Array = f.get_line().split(':', false)
		
		if ln.size() == 2:
			current_lang_map[ln[0]] = ln[1]
	
	f.close()


func get_translated_string(string: String) -> String:
	var has_letters : bool = false
	for i in range(0, string.length()):
		if _is_letter(string, i):
			has_letters = true
			break
	
	if !has_letters: return string
	
	
	var prefix : String = ""
	for i in range(0, string.length()):
		if _is_letter(string, i): break
		prefix += string[i]
	
	var translate_length : int = 0
	for i in range(prefix.length(), string.length()):
		if !_is_letter(string, i) && ord(string[i]) != ord(' ') && ord(string[i]) != ord('&') && ord(string[i]) != ord('/'): break
		translate_length += 1
	
	while string.substr(prefix.length(), translate_length).ends_with(' '):
		translate_length -= 1
	
	var suffix : String = string.substr(prefix.length() + translate_length)
	
	string = string.substr(prefix.length(), string.length() - prefix.length() - suffix.length())
	
	var capitalization_type : int = CAPITALIZATION_TYPE.KEEP
	if string == string.to_upper():
		capitalization_type = CAPITALIZATION_TYPE.UPPERCASE
	elif string[0] == string[0].to_upper() && string.substr(1) == string.substr(1).to_lower():
		capitalization_type = CAPITALIZATION_TYPE.NEUTRAL
	
	if capitalization_type != CAPITALIZATION_TYPE.KEEP:
		string = string.to_lower()
	
	string = _get_translated_string(string)
	
	match capitalization_type:
		CAPITALIZATION_TYPE.NEUTRAL:
			string = string[0].to_upper() + string.substr(1).to_lower()
		CAPITALIZATION_TYPE.UPPERCASE:
			string = string.to_upper()
	
	return prefix + string + suffix


var _not_translated := []
func _get_translated_string(string: String) -> String:
	if is_default:
		return string
	
	if string.strip_edges().empty():
		return string
	
	if string in current_lang_map:
		return current_lang_map[string]
	
	if !(string in _not_translated):
		_not_translated.append(string)
		print("No translation for \""+string+"\"!")
	return string

func _is_letter(string: String, index: int = 0) -> bool:
	var chr : int = ord(string.to_lower()[index])
	return chr >= ord('a') && chr <= ord('z')




func _ready():
	set_lang(Preferences.get_pref("lang"))

func set_lang(lang: String) -> void:
	Preferences.set_pref("lang", lang)
	load_lang_map("res://Translations/"+lang+".tres")
	_recursive_find_and_translate_text(get_tree().current_scene)

var _original_text := {}

func _recursive_find_and_translate_text(node: Node, handle_option_buttons: bool = true) -> void:
	if node.name.begins_with("NOTRANS_"):
		return
	
	if node is Label or node is Button or node is MenuDropdown:
		if node is OptionButton:
			if handle_option_buttons:
				for i in range(node.get_item_count()):
					var index : String = str(node.get_path()) + "[" + str(i) + "]"
					if !(index in _original_text):
						_original_text[index] = node.get_item_text(i)
					node.set_item_text(i, get_translated_string(_original_text[index]))
		else:
			if !(node in _original_text):
				_original_text[node] = node.text
			node.text = get_translated_string(_original_text[node])
			
			if node is MenuDropdown:
				var popup_menu : PopupMenu = node.get_popup()
				
				for i in range(popup_menu.get_item_count()):
					var index : String = str(node.get_path()) + "[" + str(i) + "]"
					if !(index in _original_text):
						_original_text[index] = popup_menu.get_item_text(i)
					popup_menu.set_item_text(i, get_translated_string(_original_text[index]))
	
	if node is LineEdit:
		if !(node in _original_text):
			_original_text[node] = node.placeholder_text
		node.placeholder_text = get_translated_string(_original_text[node])
	
	if node is WindowDialog:
		if !(node in _original_text):
			_original_text[node] = node.window_title
		node.window_title = get_translated_string(_original_text[node])
	
	if node is FileDialog:
		# the option button generated inside a file dialog is the one that lists mount points
		# do not attempt to translate that one
		handle_option_buttons = false
	
	for child in node.get_children():
		_recursive_find_and_translate_text(child, handle_option_buttons)
