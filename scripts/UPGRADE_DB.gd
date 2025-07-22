extends Node

# THIS LIST HAS TO BE EXACTLY THE SAME
# AS res://scenes/ui_upgrade_button.gd UPGRADE
# ID ENUM LIST, SAME ORDER EVEN
# IDS FOR ALL UPGRADES
enum upg_ids {
	heater_efficiency,
	heater_controller,
	skills_hp_up,
	skills_energy_up,
	skills_temp_up,
	skills_temp_down,
	freq_closer_static,
	freq_closer_relic,
	freq_,
	light_eye,
	light_core,
	lightstick,
	lightstick_glow,
	hull_defense,
	hull_insulation,
	hull_depth_max,
	static_tank,
	static_insulation,
	motor_turbo_boost,
	motor_boost_efficiency,
	batteries,
}

# MODEL THE DATA OF AN UPGRADE
class UpgradeData:
	var max_state: int
	var names: Array[String]
	var prices: Array[int]
	
	var data_by_state: Array[UpgradeDataByState] = []

class UpgradeDataByState:
	var name: String
	var price: int
	var value: Variant

# GET THE MODELED DATA OF AN UPGRADE FROM THE RAW DATA
func get_upgrade_data(upgrade_id: upg_ids) -> UpgradeData:
	if !upgrade_db.has(upgrade_id):
		printerr('NO UPGRADE DATA FOR ' + str(upgrade_id))
		return
	
	var raw_data = upgrade_db[upgrade_id]
	
	var max_state = raw_data.get("max_state", null)
	if max_state == null:
		return null
	
	var data_by_state_array = raw_data.get('data_by_state', null)
	if data_by_state_array == null:
		return null
	
	var res_data: UpgradeData = UpgradeData.new()
	res_data.max_state = max_state
	
	for level in max_state + 1:
		var data_by_state = data_by_state_array[level]
		
		res_data.data_by_state.push_back(UpgradeDataByState.new())
		res_data.data_by_state[level].name = data_by_state.get('name', 'DB: ERROR')
		res_data.data_by_state[level].price = data_by_state.get('price', -1)
		res_data.data_by_state[level].value = data_by_state.get('value', -1)
	
	return res_data

func get_upgrade_data_for_state(upgrade_id: upg_ids, state: int) -> UpgradeDataByState:
	if !upgrade_db.has(upgrade_id):
		printerr('NO UPGRADE DATA FOR ' + str(upgrade_id))
		return null
	
	var raw_data = upgrade_db[upgrade_id]
	
	var data_by_state_array = raw_data.get('data_by_state', null)
	if data_by_state_array == null:
		return null
	
	if state < 0:
		state = 0
	var data_by_state = data_by_state_array[state]
	
	var res: UpgradeDataByState = UpgradeDataByState.new()
	res.name = data_by_state.get('name', 'DB: DATA FOR STATE ERROR')
	res.price = data_by_state.get('price', -1)
	res.value = data_by_state.get('value', -1)

	return res

# RAW DATA FOR UPGRADES
# Could it be a csv? yeah, will i make it a csv? no
var upgrade_db = {
	# ---- HEATER ----
	upg_ids.heater_efficiency: {
		"max_state": 2,
		"data_by_state": [
			# 0
			{
				"name": "EFFICIENCY I",
				"price": 5000,
				"value": 1,
			},
			# 1
			{
				"name": "EFFICIENCY IV",
				"price": 10000,
				"value": 1,
			},
			# 2
			{
				"name": "EFFICIENCY MAX",
				"price": -1,
				"value": 1,
			},
		],
	},
	upg_ids.heater_controller: {
		"max_state": 1,
		"data_by_state": [
			# 0
			{
				"name": "AUTO CONTROLLER I",
				"price": 10000,
				"value": false,
			},
			# 1
			{
				"name": "AUTO CONTROLLER MAX",
				"price": -1,
				"value": true,
			},
		],
	},
	# ---- SKILLS ----
	upg_ids.skills_hp_up: {
		"max_state": 2,
		"data_by_state": [
			# 0
			{
				"name": "MECHANICAL TRANSMUTATION",
				"price": 5000,
				"value": 0,
			},
			# 1
			{
				"name": "MECHANICAL TRANSMUTATION\nEFFICIENCY",
				"price": 10000,
				"value": 1,
			},
			# 2
			{
				"name": "MECHANICAL TRANSMUTATION MAX",
				"price": -1,
				"value": 2,
			},
		],
	},
	upg_ids.skills_energy_up: {
		"max_state": 2,
		"data_by_state": [
			# 0
			{
				"name": "ENERGY TRANSMUTATION",
				"price": 5000,
				"value": 0,
			},
			# 1
			{
				"name": "ENERGY TRANSMUTATION\nEFFICIENCY",
				"price": 10000,
				"value": 1,
			},
			# 2
			{
				"name": "ENERGY TRANSMUTATION MAX",
				"price": -1,
				"value": 2,
			},
		],
	},
	upg_ids.skills_temp_up: {
		"max_state": 2,
		"data_by_state": [
			# 0
			{
				"name": "EXOTHERMAL ACTIVITY",
				"price": 5000,
				"value": 0,
			},
			# 1
			{
				"name": "EXOTHERMAL ACTIVITY\nEFFICIENCY",
				"price": 10000,
				"value": 1,
			},
			# 2
			{
				"name": "EXOTHERMAL ACTIVITY MAX",
				"price": -1,
				"value": 2,
			},
		],
	},
	upg_ids.skills_temp_down: {
		"max_state": 1,
		"data_by_state": [
			# 0
			{
				"name": "THERMAL RELEASE",
				"price": 7000,
				"value": 0,
			},
			# 1
			{
				"name": "THERMAL RELEASE MAX",
				"price": -1,
				"value": 1,
			},
		],
	},
	# ---- FREQUENCIES ----
	upg_ids.freq_closer_static: {
		"max_state": 1,
		"data_by_state": [
			# 0
			{
				"name": "CLOSER STATIC NODE",
				"price": 1000,
				"value": 0,
			},
			# 1
			{
				"name": "CLOSER STATIC NODE",
				"price": -1,
				"value": 1,
			},
		],
	},
	upg_ids.freq_closer_relic: {
		"max_state": 1,
		"data_by_state": [
			# 0
			{
				"name": "CLOSER MEAT SERVER",
				"price": 15000,
				"value": 0,
			},
			# 1
			{
				"name": "CLOSER MEAT SERVER",
				"price": -1,
				"value": 1,
			},
		],
	},
	upg_ids.freq_: {
		"max_state": 1,
		"data_by_state": [
			# 0
			{
				"name": "???",
				"price": 1,
				"value": 0,
			},
			# 1
			{
				"name": "???",
				"price": -1,
				"value": 1,
			},
		],
	},
	# ---- LIGHTS ----
	upg_ids.light_eye: {
		"max_state": 2,
		"data_by_state": [
			# 0
			{
				"name": "EYE LIGHTS I",
				"price": 5000,
				"value": 0,
			},
			# 1
			{
				"name": "EYE LIGHTS II",
				"price": 10000,
				"value": 1,
			},
			# 2
			{
				"name": "EYE LIGHTS MAX",
				"price": -1,
				"value": 2,
			},
		],
	},
	upg_ids.light_core: {
		"max_state": 3,
		"data_by_state": [
			# 0
			{
				"name": "SURROUNDING LIGHTS I",
				"price": 2500,
				"value": 0,
			},
			# 1
			{
				"name": "SURROUNDING LIGHTS II",
				"price": 5000,
				"value": 1,
			},
			# 2
			{
				"name": "SURROUNDING LIGHTS III",
				"price": 10000,
				"value": 2,
			},
			# 3
			{
				"name": "EYE LIGHTS MAX",
				"price": -1,
				"value": 3,
			},
		],
	},
	# ---- LIGHTSTICKS ----
	upg_ids.lightstick: {
		"max_state": 2,
		"data_by_state": [
			# 0
			{
				"name": "AMOUNT I",
				"price": 5000,
				"value": 5,
			},
			# 1
			{
				"name": "AMOUNT II",
				"price": 10000,
				"value": 10,
			},
			# 2
			{
				"name": "AMOUNT MAX",
				"price": -1,
				"value": 15,
			},
		],
	},
	upg_ids.lightstick_glow: {
		"max_state": 2,
		"data_by_state": [
			# 0
			{
				"name": "GLOW I",
				"price": 5000,
				"value": 0,
			},
			# 1
			{
				"name": "GLOW II",
				"price": 10000,
				"value": 1,
			},
			# 2
			{
				"name": "GLOW MAX",
				"price": -1,
				"value": 2,
			},
		],
	},
	# ---- HULL ----
	upg_ids.hull_defense: {
		"max_state": 3,
		"data_by_state": [
			# 0
			{
				"name": "DEFENSE I",
				"price": 2500,
				"value": 150,
			},
			# 1
			{
				"name": "DEFENSE II",
				"price": 7000,
				"value": 200,
			},
			# 2
			{
				"name": "DEFENSE III",
				"price": 15000,
				"value": 300,
			},
			# 3
			{
				"name": "MAX",
				"price": -1,
				"value": 500,
			},
		]
	},
	upg_ids.hull_insulation: {
		"max_state": 2,
		"data_by_state": [
			# 0
			{
				"name": "INSULATION I",
				"price": 5000,
				"value": 0,
			},
			# 1
			{
				"name": "INSULATION II",
				"price": 15000,
				"value": 1,
			},
			# 2
			{
				"name": "INSULATION MAX",
				"price": -1,
				"value": 2,
			},
		],
	},
	upg_ids.hull_depth_max: {
		"max_state": 4,
		"data_by_state": [
			# 0
			{
				"name": "MAX DEPTH I",
				"price": 5000,
				"value": 5700,
			},
			# 1
			{
				"name": "MAX DEPTH II",
				"price": 10000,
				"value": 5900,
			},
			# 2
			{
				"name": "MAX DEPTH III",
				"price": 15000,
				"value": 6300,
			},
			# 3
			{
				"name": "MAX DEPTH IV",
				"price": 25000,
				"value": 6700,
			},
			# 4
			{
				"name": "MAX",
				"price": -1,
				"value": 7500,
			},
		],
	},
	# ---- STATIC TANK ----
	upg_ids.static_tank: {
		"max_state": 3,
		"data_by_state": [
			# 0
			{
				"name": "TANK CAPACITY I",
				"price": 2500,
				"value": 2000,
			},
			# 1
			{
				"name": "TANK CAPACITY II",
				"price": 7000,
				"value": 3000,
			},
			# 2
			{
				"name": "TANK CAPACITY III",
				"price": 15000,
				"value": 5000,
			},
			# 3
			{
				"name": "MAX",
				"price": -1,
				"value": 10000,
			},
		],
	},
	upg_ids.static_insulation: {
		"max_state": 1,
		"data_by_state": [
			# 0
			{
				"name": "TANK INSULATION I",
				"price": 5000,
				"value": 0,
			},
			# 1
			{
				"name": "TANK INSULATION MAX",
				"price": -1,
				"value": 1,
			},
		],
	},
	# ---- MOTOR ----
	upg_ids.motor_turbo_boost: {
		"max_state": 2,
		"data_by_state": [
			# 0
			{
				"name": "TURBO BOOST",
				"price": 2500,
				"value": 0,
			},
			# 1
			{
				"name": "TURBO BOOST GEAR II",
				"price": 15000,
				"value": 1,
			},
			# 2
			{
				"name": "MAX",
				"price": -1,
				"value": 2,
			},
		],
	},
	upg_ids.motor_boost_efficiency: {
		"max_state": 2,
		"data_by_state": [
			# 0
			{
				"name": "EFFICIENCY I",
				"price": 10000,
				"value": 0,
			},
			# 1
			{
				"name": "EFFICIENCY II",
				"price": 15000,
				"value": 1,
			},
			# 2
			{
				"name": "EFFICIENCY MAX",
				"price": -1,
				"value": 2,
			},
		],
	},
	# ---- BATTERIES ----
	upg_ids.batteries: {
		"max_state": 3,
		"data_by_state": [
			# 0
			{
				"name": "BIGGER BATTERY I",
				"price": 2500,
				"value": 1500,
			},
			# 1
			{
				"name": "BIGGER BATTERY II",
				"price": 7000,
				"value": 2500,
			},
			# 2
			{
				"name": "BIGGER BATTERY III",
				"price": 15000,
				"value": 3500,
			},
			# 3
			{
				"name": "MAX",
				"price": -1,
				"value": 5000,
			},
		],
	},
}
