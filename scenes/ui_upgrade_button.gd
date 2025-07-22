extends Button
class_name UIUpgradeButton

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
	"hull_depth_max",
	"static_tank",
	"static_insulation",
	'motor_turbo_boost',
	'motor_boost_efficiency',
	"batteries",
)
var upgrade_id: int = 0
@onready var upgrade_data: UPGRADE_DB.UpgradeData = UPGRADE_DB.get_upgrade_data(upgrade_id)

var main_controller: MainController

func init(new_main_controller: MainController) -> void:
	main_controller = new_main_controller
	pressed.connect(main_controller._on_upgrade_clicked.bind(upgrade_id))
	hide()

# Update own data based on upgrade save state
func update_from_save() -> void:
	if !upgrade_data:
		return
	
	var save_state: int = SAVE_STATE.upgrades[upgrade_id]
	
	var data_by_state = upgrade_data.data_by_state[save_state]
	
	var is_hidden_by_relic = false
	match upgrade_id:
		# RELIC STATUES
		UPGRADE_DB.upg_ids.motor_turbo_boost:
			if save_state == 0 and !SAVE_STATE.get_relic_state(RELIC_DB.relic_ids.relic_C1_E):
				is_hidden_by_relic = true
			elif save_state == 1 and !SAVE_STATE.get_relic_state(RELIC_DB.relic_ids.relic_C2_E):
				is_hidden_by_relic = true
		
		UPGRADE_DB.upg_ids.hull_depth_max:
			if save_state == 1 and !SAVE_STATE.get_relic_state(RELIC_DB.relic_ids.relic_C1_E):
				is_hidden_by_relic = true
			if save_state == 2 and !SAVE_STATE.get_relic_state(RELIC_DB.relic_ids.relic_C2_E):
				is_hidden_by_relic = true
			if save_state == 3 and !SAVE_STATE.get_relic_state(RELIC_DB.relic_ids.relic_C3_E):
				is_hidden_by_relic = true
		
		UPGRADE_DB.upg_ids.freq_closer_relic:
			if !SAVE_STATE.get_relic_state(RELIC_DB.relic_ids.relic_C3_E):
				is_hidden_by_relic = true
		
		UPGRADE_DB.upg_ids.light_eye:
			if !SAVE_STATE.get_relic_state(RELIC_DB.relic_ids.relic_W_0):
				is_hidden_by_relic = true
		
		UPGRADE_DB.upg_ids.light_core:
			if !SAVE_STATE.get_relic_state(RELIC_DB.relic_ids.relic_W_0):
				is_hidden_by_relic = true
		
		UPGRADE_DB.upg_ids.skills_hp_up:
			if save_state == 0 and !SAVE_STATE.get_relic_state(RELIC_DB.relic_ids.relic_C0_0):
				is_hidden_by_relic = true
			if save_state == 1 and !SAVE_STATE.get_relic_state(RELIC_DB.relic_ids.relic_C3_0):
				is_hidden_by_relic = true
			
		UPGRADE_DB.upg_ids.skills_energy_up:
			if save_state == 0 and !SAVE_STATE.get_relic_state(RELIC_DB.relic_ids.relic_C0_0):
				is_hidden_by_relic = true
			if save_state == 1 and !SAVE_STATE.get_relic_state(RELIC_DB.relic_ids.relic_C3_0):
				is_hidden_by_relic = true
		
		UPGRADE_DB.upg_ids.skills_temp_up:
			if save_state == 0 and !SAVE_STATE.get_relic_state(RELIC_DB.relic_ids.relic_C2_0):
				is_hidden_by_relic = true
			if save_state == 1 and !SAVE_STATE.get_relic_state(RELIC_DB.relic_ids.relic_C3_0):
				is_hidden_by_relic = true
		
		UPGRADE_DB.upg_ids.skills_temp_down:
			if !SAVE_STATE.get_relic_state(RELIC_DB.relic_ids.relic_C2_0):
				is_hidden_by_relic = true
		
		UPGRADE_DB.upg_ids.skills_temp_up:
			if !SAVE_STATE.get_relic_state(RELIC_DB.relic_ids.relic_C2_0):
				is_hidden_by_relic = true
		
		UPGRADE_DB.upg_ids.skills_temp_down:
			if !SAVE_STATE.get_relic_state(RELIC_DB.relic_ids.relic_C2_0):
				is_hidden_by_relic = true
		
		UPGRADE_DB.upg_ids.motor_boost_efficiency:
			if !SAVE_STATE.get_relic_state(RELIC_DB.relic_ids.relic_C3_0):
				is_hidden_by_relic = true
		
		UPGRADE_DB.upg_ids.heater_efficiency:
			if !SAVE_STATE.get_relic_state(RELIC_DB.relic_ids.relic_C3_0):
				is_hidden_by_relic = true
		
		UPGRADE_DB.upg_ids.heater_controller:
			if !SAVE_STATE.get_relic_state(RELIC_DB.relic_ids.relic_C3_1):
				is_hidden_by_relic = true
		
		UPGRADE_DB.upg_ids.hull_insulation:
			if !SAVE_STATE.get_relic_state(RELIC_DB.relic_ids.relic_C3_2):
				is_hidden_by_relic = true
		
		UPGRADE_DB.upg_ids.static_insulation:
			if !SAVE_STATE.get_relic_state(RELIC_DB.relic_ids.relic_C3_2):
				is_hidden_by_relic = true
		
		_:
			pass
	
	if save_state < 0 or is_hidden_by_relic:
		disabled = true
		text = "HIDE"
		hide()
		return
	
	#> UPGRADE NAME
	#00000000
	var current_text = data_by_state.name
	var current_price = data_by_state.price
	text = "> " + current_text + "\n" + str(current_price)
	
	show()
	
	disabled = main_controller.available_static < current_price
	
