extends Control

@onready var crush_depth_label = $crush_depth_label
@onready var cost_label = $cost_label
@onready var upgrade_depth_button = $upgrade_depth_button

#func _ready() -> void:
	#update_crush_depth(5900)
	#update_cost(1000)
	#update_upgrade_btn_disabled(true)


func update_crush_depth(new_crush_depth: int) -> void:
	crush_depth_label.text = "CRUSH DEPTH: " + thousands_sep(new_crush_depth)

func update_cost(new_cost: int) -> void:
	cost_label.text = "COST: " + thousands_sep(new_cost)

func update_upgrade_btn_disabled(new_state: bool) -> void:
	upgrade_depth_button.disabled = new_state

static func thousands_sep(number: int):
	var string = str(number)
	var mod = string.length() % 3
	var res = ""
	for i in range(0, string.length()):
		if i != 0 && i % 3 == mod:
			res += "."
		res += string[i]
	
	return res
