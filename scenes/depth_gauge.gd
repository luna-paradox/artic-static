extends Control

@onready var label = $depth_gauge/label

#func _ready() -> void:
	#update_depth(5012)

func update_depth(new_depth: int) -> void:
	label.text = thousands_sep(new_depth)

static func thousands_sep(number: int):
	var string = str(number)
	var mod = string.length() % 3
	var res = ""
	for i in range(0, string.length()):
		if i != 0 && i % 3 == mod:
			res += "."
		res += string[i]
	
	return res
