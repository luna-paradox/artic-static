extends Control

@onready var desc_label = $desc_label
@onready var cost_label = $cost_label
@onready var upgrade_button = $upgrade_button
@export var label_prefix = ""


func update_value(new_value: int) -> void:
	desc_label.text = label_prefix + "\n" + thousands_sep(new_value)

func update_cost(new_cost: int) -> void:
	cost_label.text = "COST: " + thousands_sep(new_cost)

func update_upgrade_btn_disabled(new_state: bool) -> void:
	upgrade_button.disabled = new_state

static func thousands_sep(number: int):
	var string = str(number)
	var mod = string.length() % 3
	var res = ""
	for i in range(0, string.length()):
		if i != 0 && i % 3 == mod:
			res += "."
		res += string[i]
	
	return res
