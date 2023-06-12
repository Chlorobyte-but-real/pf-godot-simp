extends MenuDropdown

func setup() -> void:
	events = {
		"Undo (Ctrl+Z)": [ UndoLog, "undo" ],
		"Redo (Ctrl+Shift+Z)": [ UndoLog, "redo" ],
	}
	enable_conditions = {
		"Undo (Ctrl+Z)": [ UndoLog, "can_undo" ],
		"Redo (Ctrl+Shift+Z)": [ UndoLog, "can_redo" ],
	}
