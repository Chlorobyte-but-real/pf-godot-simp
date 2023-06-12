extends HBoxContainer


func _process(_delta) -> void:
	$Label.text = str($"../../../ImageEditLayer".scale.x * 100)+"%"
