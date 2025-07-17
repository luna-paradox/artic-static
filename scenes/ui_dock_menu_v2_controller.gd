extends CanvasLayer

@onready var all_upgrade_buttons = [
	$main_container/upgrade_box_container/heater_upgrade_ui/v_box_container/efficiency,
	$main_container/upgrade_box_container/heater_upgrade_ui/v_box_container/heater_controller,
]

var main_controller: MainController

func init(new_main_controller: MainController):
	main_controller = new_main_controller
	
	for button in all_upgrade_buttons:
		button.init(main_controller)
	
	upgrade_ui_based_on_save_data()

# Trigger every button to update its data from the upgrade save state
func upgrade_ui_based_on_save_data():
	for button in all_upgrade_buttons:
		button.update_from_save()
