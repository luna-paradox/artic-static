extends Button

# THIS LIST HAS TO BE EXACTLY THE SAME
# AS UPGRADE_DB.upg_ids, SAME ORDER EVEN
@export_enum(
	"heater_efficiency",
	"heater_controller",
	"skills_hp_up",
	"skills_energy_up",
	"skills_temp_up",
	"skills_temp_down",
	"freq_closer_static",
	"freq_closer_relic",
	"freq_",
	"light_eye",
	"light_core",
	"lightstick",
	"lightstick_glow",
	"hull_defense",
	"hull_insulation",
	"depth_max",
	"static_tank",
	"static_insulation",
	'motor_turbo_boost',
	'motor_boost_efficiency',
	"batteries",
)
var upgrade_id: int = 0
@onready var upgrade_data = UPGRADE_DB.get_upgrade_data(upgrade_id)

var main_controller: MainController

func init(new_main_controller: MainController) -> void:
	main_controller = new_main_controller
	pressed.connect(main_controller._on_upgrade_clicked.bind(upgrade_id))
	hide()

# Update own data based on upgrade save state
func update_from_save() -> void:
	var save_state = SAVE_STATE.upgrades[upgrade_id]

	if save_state == null or save_state >= upgrade_data.max_state:
		disabled = true
		text = "HIDE"
		hide()
		return
	
	#> UPGRADE NAME
	#00000000
	var current_text: String = upgrade_data.names[save_state]
	var current_price: int = upgrade_data.prices[save_state]
	text = "> " + current_text + "\n" + str(current_price)
	
	show()
	
	disabled = main_controller.available_static < current_price
	
