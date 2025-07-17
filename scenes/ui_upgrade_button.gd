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

var main_controller: MainController

func init(new_main_controller: MainController) -> void:
	main_controller = new_main_controller
	
	pressed.connect(main_controller._on_upgrade_clicked.bind(upgrade_id))

func update(new_desc: String, new_price: int, new_disabled: bool) -> void:
	#> EFFICIENCY
	#00000000
	text = "> " + new_desc + "\n" + str(new_price)
	disabled = new_disabled
