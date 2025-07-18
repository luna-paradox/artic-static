extends Node

# Move the state of an upgrade save state by delta
func update_upgrade_state(upgrade_id: UPGRADE_DB.upg_ids, delta: int) -> int:
	if upgrades[upgrade_id] == null:
		upgrades[upgrade_id] = delta - 1
		return upgrades[upgrade_id]
	
	upgrades[upgrade_id] += delta
	return upgrades[upgrade_id]

# UPGRADE SAVE DATA
# -1 means hidden
# from 0 state values are case by case
# controlled by the all powerful main_controller.gd
# using data from UPGRADE_DB.gd
var upgrades = {
	UPGRADE_DB.upg_ids.heater_efficiency: -1,
	UPGRADE_DB.upg_ids.heater_controller: -1,
	UPGRADE_DB.upg_ids.skills_hp_up: 0,
	UPGRADE_DB.upg_ids.skills_energy_up: 0,
	UPGRADE_DB.upg_ids.skills_temp_up: 0,
	UPGRADE_DB.upg_ids.skills_temp_down: 0,
	UPGRADE_DB.upg_ids.freq_closer_static: 0,
	UPGRADE_DB.upg_ids.freq_closer_relic: 0,
	UPGRADE_DB.upg_ids.freq_: 0,
	UPGRADE_DB.upg_ids.light_eye: -1,
	UPGRADE_DB.upg_ids.light_core: -1,
	UPGRADE_DB.upg_ids.lightstick: 0,
	UPGRADE_DB.upg_ids.lightstick_glow: 0,
	UPGRADE_DB.upg_ids.hull_defense: 0,
	UPGRADE_DB.upg_ids.hull_insulation: 0,
	UPGRADE_DB.upg_ids.hull_depth_max: 0,
	UPGRADE_DB.upg_ids.static_tank: 0,
	UPGRADE_DB.upg_ids.static_insulation: 0,
	UPGRADE_DB.upg_ids.motor_turbo_boost: 0,
	UPGRADE_DB.upg_ids.motor_boost_efficiency: 0,
	UPGRADE_DB.upg_ids.batteries: 0,
}

#var upgrades = {
	#UPGRADE_DB.upg_ids.heater_efficiency: -1,
	#UPGRADE_DB.upg_ids.heater_controller: -1,
	#UPGRADE_DB.upg_ids.skills_hp_up: -1,
	#UPGRADE_DB.upg_ids.skills_energy_up: -1,
	#UPGRADE_DB.upg_ids.skills_temp_up: -1,
	#UPGRADE_DB.upg_ids.skills_temp_down: -1,
	#UPGRADE_DB.upg_ids.freq_closer_static: -1,
	#UPGRADE_DB.upg_ids.freq_closer_relic: -1,
	#UPGRADE_DB.upg_ids.freq_: -1,
	#UPGRADE_DB.upg_ids.light_eye: -1,
	#UPGRADE_DB.upg_ids.light_core: -1,
	#UPGRADE_DB.upg_ids.lightstick: -1,
	#UPGRADE_DB.upg_ids.lightstick_glow: -1,
	#UPGRADE_DB.upg_ids.hull_defense: 0,
	#UPGRADE_DB.upg_ids.hull_insulation: -1,
	#UPGRADE_DB.upg_ids.hull_depth_max: 0,
	#UPGRADE_DB.upg_ids.static_tank: 0,
	#UPGRADE_DB.upg_ids.static_insulation: -1,
	#UPGRADE_DB.upg_ids.motor_turbo_boost: -1,
	#UPGRADE_DB.upg_ids.motor_boost_efficiency: -1,
	#UPGRADE_DB.upg_ids.batteries: 0,
#}
