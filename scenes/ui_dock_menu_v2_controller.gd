extends CanvasLayer

@onready var all_upgrade_buttons = find_all_upgrade_buttons()
@onready var all_upgrade_containers = find_all_upgrade_containers()
@onready var upgrade_beep = $audio/upgrade_beep
@onready var upgrade_clicks = [
	$audio/upgrade_click_0,
	$audio/upgrade_click_1,
	$audio/upgrade_click_2,
	$audio/upgrade_click_3,
]
@onready var static_counter_label = $main_container/static_counter/label

var main_controller: MainController

func init(new_main_controller: MainController):
	main_controller = new_main_controller
	
	for button in all_upgrade_buttons:
		button.init(main_controller)
		button.mouse_entered.connect(_on_button_mouse_entered.bind(button))
	
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

func _on_button_mouse_entered(button: Button):
	if button.disabled:
		return
	upgrade_beep.play()

func play_upgrade_click_sfx():
	var random_index = randi() % 4
	upgrade_clicks[random_index].play()

func upgrade_static_counter(new_value: int) -> void:
	static_counter_label.text = "STATIC: " + str(new_value)

# Trigger every button to update its data from the upgrade save state
func upgrade_ui_based_on_save_data():
	for button in all_upgrade_buttons:
		button.update_from_save()
	
	for container in all_upgrade_containers:
		var buttons = find_all_upgrade_buttons(container)
		container.hide()
		container.overlay_ui.hide()
		for button in buttons:
			if button.visible:
				container.show()
				container.overlay_ui.show()
				break

#TODO UPGRADE UI SFX
#TODO MAKE IT SO MAXED OUT UPGRADES DON'T DISSAPEAR BUT HAVE A COOLER LOOK
#TODO COLOR CODE THE STATE OF THE UPGRADE

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

# Recursively search for all upgrade containers on the tree
# based on the class_name UIUpgradeContainer
func find_all_upgrade_containers(node: Node = null) -> Array:
	if node == null:
		node = self
	
	var result := []
	for child in node.get_children():
		if child is UIUpgradeContainer:
			result.append(child)
			print(child.name)
		
		result += find_all_upgrade_containers(child)
	
	return result
