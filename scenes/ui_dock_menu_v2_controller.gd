extends CanvasLayer

@onready var all_upgrade_buttons = find_all_upgrade_buttons()

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

# Recursively search for all upgrade buttons on the tree
# based on the class_name UIUpgradeButton
func find_all_upgrade_buttons(node: Node = null) -> Array:
	if node == null:
		node = self
	
	var result := []
	for child in node.get_children():
		if child is UIUpgradeButton:
			result.append(child)
		
		result += find_all_upgrade_buttons(child)
	
	return result
