extends CanvasLayer

@onready var all_upgrades = [
	{
		"button": $main_container/upgrade_box_container/heater_upgrade_ui/v_box_container/efficiency
	},
	{
		"button": $main_container/upgrade_box_container/heater_upgrade_ui/v_box_container/heater_controller
	},
]

var main_controller: MainController

func init(new_main_controller: MainController):
	main_controller = new_main_controller
	
	for upgrade in all_upgrades:
		upgrade["button"].init(main_controller)
	
	upgrade_ui_based_on_save_data()

func upgrade_ui_based_on_save_data():
	for upgrades in all_upgrades:
		setup_button(upgrades["button"])

# Setup a button from its ID
func setup_button(button: Button):
	var upgrade_data = UPGRADE_DB.get_upgrade_data(button.upgrade_id)
	var save_state = SAVE_STATE.upgrades[button.upgrade_id]
	
	if save_state == null or save_state >= upgrade_data.max_state:
		button.update("HIDE", 0, true)
		button.hide()
		return
	
	var new_text: String = upgrade_data.names[save_state]
	var new_price: int = upgrade_data.prices[save_state]
	var new_disabled = main_controller.available_static < new_price
	
	button.update(new_text, new_price, new_disabled)
	button.show()
