extends Node
# UPGRADE SAVE DATA
# -1 means hidden
# from 0 state values are case by case
# controlled by the all powerful main_controller.gd
# using data from UPGRADE_DB.gd
var upgrades = {
	UPGRADE_DB.upg_ids.heater_efficiency: 0,
	UPGRADE_DB.upg_ids.heater_controller: 0,
	UPGRADE_DB.upg_ids.skills_hp_up: 0,
	UPGRADE_DB.upg_ids.skills_energy_up: 0,
	UPGRADE_DB.upg_ids.skills_temp_up: 0,
	UPGRADE_DB.upg_ids.skills_temp_down: 0,
	UPGRADE_DB.upg_ids.freq_closer_static: 0,
	UPGRADE_DB.upg_ids.freq_closer_relic: 0,
	UPGRADE_DB.upg_ids.freq_: 0,
	UPGRADE_DB.upg_ids.light_eye: 0,
	UPGRADE_DB.upg_ids.light_core: 0,
	UPGRADE_DB.upg_ids.lightstick: 0,
	UPGRADE_DB.upg_ids.lightstick_glow: 0,
	UPGRADE_DB.upg_ids.hull_defense: 3,
	UPGRADE_DB.upg_ids.hull_insulation: 0,
	UPGRADE_DB.upg_ids.hull_depth_max: 0,
	UPGRADE_DB.upg_ids.static_tank: 0,
	UPGRADE_DB.upg_ids.static_insulation: 0,
	UPGRADE_DB.upg_ids.motor_turbo_boost: 0,
	UPGRADE_DB.upg_ids.motor_boost_efficiency: 0,
	UPGRADE_DB.upg_ids.batteries: 0,
}

var events = {
	EVENT_DB.event_id.talk_statue_c1: false,
	EVENT_DB.event_id.talk_statue_c2: false,
	EVENT_DB.event_id.talk_statue_c3: false,
}

var relics = {
	RELIC_DB.relic_ids.relic_C0_0: false,
	RELIC_DB.relic_ids.relic_C1_E: false,
	RELIC_DB.relic_ids.relic_W_0: false,
	RELIC_DB.relic_ids.relic_C2_E: false,
	RELIC_DB.relic_ids.relic_C2_0: false,
	RELIC_DB.relic_ids.relic_C3_E: false,
	RELIC_DB.relic_ids.relic_C3_0: false,
	RELIC_DB.relic_ids.relic_C3_1: false,
	RELIC_DB.relic_ids.relic_C3_2: false,
}

# ---- RELIC STATES ----

# Toggle a relic save state to true
func enable_relic_state(relic_id: RELIC_DB.relic_ids) -> void:
	relics[relic_id] = true

# Get the save state of a relic
func get_relic_state(relic_id: RELIC_DB.relic_ids) -> bool:
	var relic_state: bool = relics[relic_id]
	return relic_state

# ---- UPGRADE STATES ----

# Move the save state of an upgrade save state by delta
func update_upgrade_state(upgrade_id: UPGRADE_DB.upg_ids, delta: int) -> int:
	if upgrades[upgrade_id] == null:
		upgrades[upgrade_id] = delta - 1
		return upgrades[upgrade_id]
	
	upgrades[upgrade_id] += delta
	return upgrades[upgrade_id]
