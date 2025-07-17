extends CanvasLayer

@onready var all_upgrade_buttons = [
	$main_container/upgrade_box_container/heater_upgrade_ui/v_box_container/efficiency,
	$main_container/upgrade_box_container/heater_upgrade_ui/v_box_container/heater_controller,
	$main_container/upgrade_box_container/skill_upgrade_ui/v_box_container/hp_up,
	$main_container/upgrade_box_container/skill_upgrade_ui/v_box_container/energy_up,
	$main_container/upgrade_box_container/skill_upgrade_ui/v_box_container/temp_up,
	$main_container/upgrade_box_container/skill_upgrade_ui/v_box_container/temp_down,
]



var main_controller: MainController

func init(new_main_controller: MainController):
	main_controller = new_main_controller
	
	for button in all_upgrade_buttons:
		button.init(main_controller)
	
	upgrade_ui_based_on_save_data()
	
	#var skill_container = $main_container/upgrade_box_container/skill_upgrade_ui
	#var skill_anchor = $main_container/upgrade_box_container/anchors/skill_anchor
	#var skill_line = $main_container/upgrade_box_container/skill_upgrade_ui/Line2D
	#skill_line.points[1] = skill_anchor.position - skill_container.position
	
	#print("LINE POINT")
	#print(skill_line.points[1])
	#print("ANCHOR POSITION")
	#print(skill_anchor.position)
	#print("SKILL CONTAINER POSITION")
	#print(skill_container.position)
	#print("SKILL CONTAINER GLOBAL POSITION")
	#print(skill_container.global_position)
	

# Trigger every button to update its data from the upgrade save state
func upgrade_ui_based_on_save_data():
	for button in all_upgrade_buttons:
		button.update_from_save()
