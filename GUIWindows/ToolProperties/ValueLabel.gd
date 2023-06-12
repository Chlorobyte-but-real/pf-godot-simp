extends Label

func _process(_delta) -> void:
	text = str($"../".value) + ("%" if $"../".name == "ValuePercent" else ("°" if $"../".name == "ValueDegrees" else ""))
