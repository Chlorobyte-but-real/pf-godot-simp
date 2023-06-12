extends MenuDropdown

func setup() -> void:
	events = {
		"New": [ $"../../../../../ImageEditLayer", "new_open_dialog" ],
		"Open...": [ $"../../../../../ImageEditLayer", "load_open_dialog" ],
		"Import image to layer": [ $"../../../../../ImageEditLayer", "import_open_dialog" ],
		"Save project": [ $"../../../../../ImageEditLayer", "save_open_dialog" ],
		"Export as image": [ $"../../../../../ImageEditLayer", "export_open_dialog" ],
	}
	enable_conditions = {
		"Import image to layer": [ $"../../../../../ImageEditLayer/ImageDisplay", "exists" ],
		"Save project": [ $"../../../../../ImageEditLayer/ImageDisplay", "exists" ],
		"Export as image": [ $"../../../../../ImageEditLayer/ImageDisplay", "exists" ],
	}
