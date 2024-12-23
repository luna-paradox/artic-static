extends Node
class_name MainController

# CAMERA
@onready var camera = $camera
# PLAYER
@onready var player = $player
@onready var player_alert_0 = $player/alert_0
@onready var player_start_pos = $player_start_pos
@onready var diegetic_ui = $player/diegetic_ui
# CAGE
@onready var cage_sprite_top = $room/BASE/cage_front 
# UI
@onready var hp_bar = $ui_exploration/top_left/hp_bar
@onready var energy_bar = $ui_exploration/top_left/energy_bar
@onready var static_bar = $ui_exploration/top_right/static_bar
@onready var game_over_overlay = $game_over_overlay
@onready var depth_gauge = $ui_exploration/top_center/depth_gauge
@onready var depth_max_ui = $ui_exploration/top_center/depth_max
@onready var instructions_ui = $instructions_screen
# UI DOCK MENU
@onready var alert_docking = $ui_exploration/top_right/dock_alert/docking_icon
@onready var alert_can_dock = $ui_exploration/top_right/dock_alert/can_dock
@onready var dock_menu = $ui_dock_menu
@onready var dock_enable_sound = $global_audio/dock_enable_sound
@onready var dock_menu_static_counter_label = $ui_dock_menu/container/static_counter/label
@onready var upgrade_crush_depth_ui = $ui_dock_menu/container/depth_upgrade
@onready var shop_third_eye_ui = $ui_dock_menu/container/third_eye_ui
# AUDIO
@onready var sub_explossion = $global_audio/sub_explossion
@onready var background_sound_0 = $global_audio/background_sound_0
@onready var collecting_static_sound = $global_audio/collecting_static_sound
@onready var getting_crushed_sound = $global_audio/getting_crushed_sound
@onready var secret_success_sound = $global_audio/secret_success_sound
@onready var sonar_sound = $global_audio/sonar_sound
# PROGRESS
@onready var third_eye = $ui_exploration/top_right/third_eye

@onready var area_1 = $room/A1
@onready var area_1_door = $room/A1_wall_to_hide
@onready var area_2 = $room/A2
@onready var area_2_door = $room/A2_wall_to_hide
@onready var area_3 = $room/A3
@onready var area_3_door = $room/A3_wall_to_hide
@onready var follow_the_eye_ui = $follow_the_eye_ui

# ---- MOVEMENT STATS ----
@export var ACCELERATION: int = 200
@export var DECELERATION: int = 100
@export var MAX_SPEED: int = 450

# ---- OTHER STATS ----
@export var STATIC_CONSUMPTION_RATE = 150
@export var TURBO_BOOST_ENERGY_RATE = 100

# ---- DEPTH ----
@export var CRUSH_DEPTH = 5800
var current_depth = 5550

# ---- STORE ----
# Cost in Static
@export var CRUSH_DEPTH_UPGRADE = 1000


# ---- PROGRESS ----
var static_historic = 0

@export var STATIC_HISTORIC_FOR_THIRD_EYE = 2000
var have_third_eye = false

var progress_status = 0


# ---- OTHERS ----
var pause = false
var crusher_timer: Timer

func _ready() -> void:
	$global_mod.show()
	$camera.show()
	alert_docking.hide()
	alert_can_dock.hide()
	close_dock_menu()
	area_1.hide()
	area_2.hide()
	area_3.hide()
	
	current_hp = MAX_HP
	player.main_controller = self
	player.init(ACCELERATION, DECELERATION, MAX_SPEED)
	
	crusher_timer = Timer.new()
	crusher_timer.wait_time = 0.5
	crusher_timer.one_shot = true
	crusher_timer.timeout.connect(damage_by_pressure)
	add_child(crusher_timer)
	
	upgrade_crush_depth_ui.update_crush_depth(CRUSH_DEPTH)
	upgrade_crush_depth_ui.update_cost(CRUSH_DEPTH_UPGRADE)
	
	hp_bar.init(MAX_HP)
	static_bar.init(MAX_PLAYER_STATIC, player_current_static)
	energy_bar.init(MAX_ENERGY)
	depth_max_ui.update_depth(CRUSH_DEPTH)
	
	third_eye.mode = 0
	restart()
	#show_instructions()

func _process(delta: float) -> void:
	camera.global_position = player.global_position
	if pause:
		return
	
	# UPDATE DEPTH GAUGE
	current_depth = player.global_position.y/20 + 5550
	depth_gauge.update_depth(current_depth)
	
	# TEMPERATURE CONTROL
	control_temp(delta)
	
	if is_heater_on:
		var delta_energy = -HEATER_ENERGY_COST * heater_power * delta
		update_energy(delta_energy)
		
		if current_energy <= 0:
			update_heater_state(false)
	
	# CRUSH BY DEPTH
	if current_depth > CRUSH_DEPTH and crusher_timer.is_stopped():
		crusher_timer.start()
	
	crush_by_depth_audio(delta)
	
	# TURBO BOOST 
	if player.is_boosting:
		var speed = player.velocity.length()
		var speed_index = speed / player.MAX_SPEED
		# Reverse Tagent growrth to energy usage vs speed percentage
		var speed_modifier = 0.7 * atan(rad_to_deg(7 * speed_index))
		
		update_energy(-delta * TURBO_BOOST_ENERGY_RATE * speed_modifier)
		
		if current_energy <= 0:
			player.disable_turbo_boost()
	
	#INTERACT WITH STATIC NODES
	if Input.is_action_pressed("interact") and static_nodes_in_range.size() > 0:
		var delta_static = delta * STATIC_CONSUMPTION_RATE
		update_static(delta_static)
		var is_depleted = static_nodes_in_range[0].consume(delta_static)
		update_collecting_static(!is_depleted)
	elif collecting_static and Input.is_action_just_released("interact"):
		update_collecting_static(false)
	elif static_nodes_in_range.size() == 0:
		update_collecting_static(false)

func _input(event: InputEvent) -> void:
	# DEBUG 
	if event.is_action_pressed("exit_debug"):
		get_tree().quit()
		return
	
	if event.is_action_pressed("1_debug"):
		progress(third_eye.mode + 1)
		return
	if event.is_action_pressed("2_debug"):
		update_static(500)
		return
	
	# WHILE INSTRUCTIONS ARE VISIBLE
	if instructions_ui.visible:
		if event.is_action_pressed("close_instruction"):
			hide_instructions()
		return
	
	# WHILE DOCK MENU IS VISIBLE
	if dock_menu.visible:
		if event.is_action_pressed("exit_dock"):
			close_dock_menu()
		return
	
	# PAUSE MEANS NOT MOVING AROUND
	if pause:
		return
	
	if event.is_action_pressed("turn_sub"):
		player.scale.x *= -1
		return
	
	# WHILE MOVING AROUND
	if event.is_action_pressed("interact") and can_dock:
		start_dock_menu()
		return
	
	if event.is_action_pressed("sonar_action"):
		sonar()
		return
	
	if event.is_action_pressed("heater_action"):
		update_heater_state(!is_heater_on)
		return
	
	if event.is_action_pressed("turbo_boost_action") and current_energy > 0:
		player.turbo_boost()
		return
	elif event.is_action_released("turbo_boost_action"):
		player.disable_turbo_boost()
		return
	
	# PROGRESS
	if can_interact_with_statue_p2 and event.is_action_pressed("interact") and third_eye.mode == 2:
		progress(3)
		return
	
	if can_interact_with_statue_p4 and event.is_action_pressed("interact") and third_eye.mode == 4:
		progress(5)
		return


# ---- STATS ----
@export var MAX_HP = 200
var current_hp = 200
@export var MAX_ENERGY: float = 1000.0
var current_energy: float = 1000.0
@export var MAX_PLAYER_STATIC = 5000.0
# Static stored on the submarine
var player_current_static = 0.0
# Static stored on the base
var available_static = 0

func update_hp(delta_hp: int) -> void:
	#print('UPDATE HP: ' + str(delta_hp))
	
	#UPDATE DATA
	current_hp += delta_hp
	
	if current_hp > MAX_HP:
		current_hp = MAX_HP
	elif current_hp < 0:
		current_hp = 0
	
	#UPDATE UI
	hp_bar.update_bar(current_hp)
	
	if current_hp <= 0:
		# SFX 
		if !sub_explossion.playing:
			sub_explossion.play()
		
		game_over()
		return

func update_energy(delta_energy: float) -> void:
	#print('UPDATE ENERGY: ' + str(delta_energy))
	
	#UPDATE DATA
	current_energy += delta_energy
	current_energy = round(current_energy*100.0) / 100.0
	
	if current_energy > MAX_ENERGY:
		current_energy = MAX_ENERGY
	elif current_energy < 0:
		current_energy = 0
	
	#UPDATE UI
	energy_bar.update_bar(current_energy)

func update_static(delta_static: float) -> void:
	#print('UPDATE STATIC: ' + str(delta_static))
	
	#UPDATE DATA
	player_current_static += delta_static
	
	if player_current_static > MAX_PLAYER_STATIC:
		player_current_static = MAX_PLAYER_STATIC
	elif player_current_static < 0:
		player_current_static = 0
	
	#UPDATE UI
	static_bar.update_bar(player_current_static)

func update_available_static(delta_static: int):
	available_static += delta_static
	dock_menu_static_counter_label.text = "STATIC: " + str(available_static)

var collecting_static = false
func update_collecting_static(new_state: bool) -> void:
	if collecting_static == new_state:
		return
	collecting_static = new_state
	
	# SFX
	if collecting_static and !collecting_static_sound.playing:
		collecting_static_sound.play()
	elif !collecting_static and collecting_static_sound.playing:
		collecting_static_sound.stop()

func update_temp(delta_temp: float):
	delta_temp = round(delta_temp * 100.0) / 100.0
	
	#UPDATE DATA
	current_temp += delta_temp
	current_temp = round(current_temp * 100.0) / 100.0
	
	if current_temp > MAX_TEMP:
		current_temp = MAX_TEMP
	elif current_temp < MIN_TEMP:
		current_temp = MIN_TEMP
	
	#TODO UPDATE UI
	#print(current_temp)
	pass


# ---- GAME OVER ----
func restart():
	game_over_overlay.hide()
	
	player.velocity = Vector2.ZERO
	player.disable_turbo_boost()
	player.global_position = player_start_pos.global_position
	
	update_hp(MAX_HP)
	update_energy(MAX_ENERGY)
	update_temp(20 - current_temp)
	update_static(-MAX_PLAYER_STATIC)
	
	update_heater_power(0.5)
	update_heater_state(true)
	
	reset_all_static_nodes()
	background_sound_0.play()
	
	camera.position_smoothing_enabled = false
	camera.global_position = player.global_position
	await get_tree().process_frame
	camera.position_smoothing_enabled = true
	
	update_pause(false)

func game_over() -> void:
	background_sound_0.stop()
	game_over_overlay.show()
	update_pause(true)

func _on_restart_btn_pressed() -> void:
	restart()

func reset_all_static_nodes() -> void:
	for node in get_all_static_nodes($room):
		node.reset()


# ---- STATIC NODES ----
var static_nodes_in_range: Array[Node2D] = []

func _on_player_interaction_area_entered(area: Area2D) -> void:
	static_nodes_in_range.append(area.get_parent())
	player_alert_0.show()

func _on_player_interaction_area_exited(area: Area2D) -> void:
	static_nodes_in_range.erase(area.get_parent())
	if static_nodes_in_range.size() <= 0:
		player_alert_0.hide()


# ---- PAUSE GAME ----
func update_pause(new_state: bool) -> void:
	pause = new_state
	player.update_pause(new_state)
	
	if new_state:
		getting_crushed_sound.stop()


# ---- THE CAGE ----
# GENERAL CAGE AREA
func _on_cage_area_2d_area_entered(area: Area2D) -> void:
	#print(area.name)
	if area.name == "player_area_2D":
		alert_docking.show()

func _on_cage_area_2d_area_exited(area: Area2D) -> void:
	#print(area.name)
	if area.name == "player_area_2D":
		alert_docking.hide()

# INTERACTION CAGE AREA
var can_dock = false
func _on_cage_interaction_area_2d_area_entered(area: Area2D) -> void:
	if area.name != 'player_cage_interaction_area_2d':
		return
	can_dock = true
	alert_can_dock.show()

func _on_cage_interaction_area_2d_area_exited(area: Area2D) -> void:
	if area.name != 'player_cage_interaction_area_2d':
		return
	can_dock = false
	alert_can_dock.hide()


# ---- DOCKER MENU ----
func _on_ui_dock_menu_close_btn_pressed() -> void:
	close_dock_menu()

func start_dock_menu() -> void:
	# PAUSE
	update_pause(true)
	
	# UNLOAD STATIC
	if player_current_static > 0:
		static_historic += player_current_static
		update_available_static(player_current_static)
		update_static(-player_current_static)
	
	# REPAIR SUBMARINE
	update_hp(MAX_HP)
	update_energy(MAX_ENERGY)
	update_temp(20 - current_temp)
	
	# RESTART ALL STATIC NODES
	reset_all_static_nodes()
	
	# SFX
	#if !dock_enable_sound.playing:
	dock_enable_sound.play()
	
	if !have_third_eye and static_historic > STATIC_HISTORIC_FOR_THIRD_EYE:
		shop_third_eye_ui.show()
	else:
		shop_third_eye_ui.hide()
	
	var can_buy_depth = CRUSH_DEPTH_UPGRADE >= available_static
	upgrade_crush_depth_ui.update_upgrade_btn_disabled(can_buy_depth)
	
	# SHOW MENU
	dock_menu.show()

func close_dock_menu() -> void:
	dock_menu.hide()
	update_pause(false)

func _on_upgrade_depth_button_pressed() -> void:
	if CRUSH_DEPTH_UPGRADE > available_static:
		return
	
	update_available_static(-CRUSH_DEPTH_UPGRADE)
	CRUSH_DEPTH += 100
	CRUSH_DEPTH_UPGRADE *= 1.05
	
	depth_max_ui.update_depth(CRUSH_DEPTH)
	upgrade_crush_depth_ui.update_crush_depth(CRUSH_DEPTH)
	upgrade_crush_depth_ui.update_cost(CRUSH_DEPTH_UPGRADE)
	
	var can_buy_depth = CRUSH_DEPTH_UPGRADE >= available_static
	upgrade_crush_depth_ui.update_upgrade_btn_disabled(can_buy_depth)


# ---- CRUSHING ----
var current_crashing_volume = 0

func damage_by_pressure() -> void:
	update_hp(MAX_HP * -0.15)

func crush_by_depth_audio(delta: float) -> void:
	if current_depth > CRUSH_DEPTH and !getting_crushed_sound.playing:
		getting_crushed_sound.play()
		current_crashing_volume = 0
		getting_crushed_sound.volume_db = linear_to_db(current_crashing_volume)
	if current_depth > CRUSH_DEPTH and getting_crushed_sound.playing:
		current_crashing_volume += 1 * delta
		if current_crashing_volume > 1:
			current_crashing_volume = 1
		getting_crushed_sound.volume_db = linear_to_db(current_crashing_volume)
	elif current_depth <= CRUSH_DEPTH and getting_crushed_sound.playing:
		current_crashing_volume -= 3 * delta
		if current_crashing_volume < 0:
			current_crashing_volume = 0
		getting_crushed_sound.volume_db = linear_to_db(current_crashing_volume)
	
	if current_crashing_volume == 0:
		getting_crushed_sound.stop()


# ---- SONNAR ----
func get_nearest_static_node() -> Node2D:
	var nearest_node: Node2D = null
	var shorteest_distance: float = 0.0
	
	for node in get_all_static_nodes($room):
		if !node.enabled:
			continue
		
		var distance = node.global_position.distance_to(player.global_position)
		if nearest_node == null:
			shorteest_distance = distance
			nearest_node = node
		elif distance < shorteest_distance:
			shorteest_distance = distance
			nearest_node = node
	
	return nearest_node

func sonar(): 
	if !player.is_sonar_enabled:
		sonar_sound.play()
		var nearest_static_node = get_nearest_static_node()
		player.activate_sonar(nearest_static_node)


# ---- TEMPERATURE ----
var MAX_TEMP: float = 100
var MIN_TEMP: float = -10
var current_temp: float = 9.0
var current_heat_transfer: float = 0.0
var TEMP_TRANSFER_ENVIRONMENT: float = -0.5
var TEMP_TRANSFER_BOOSTING: float = 0.3
var TEMP_TRANSFER_STATIC_FACTOR: float = -0.1 / 400 # X°C by each Y static

var temp_action_counter = 0
func control_temp(delta: float) -> void:
	temp_action_counter += delta
	if temp_action_counter < 1.0:
		return
	
	temp_action_counter = 0.0
	
	# CALCULATE HEAT TRANSFER
	var heat_transfer = TEMP_TRANSFER_ENVIRONMENT
	
	if is_heater_on:
		heat_transfer += calculate_heater_heat_transfer()
	if player.is_boosting:
		heat_transfer += TEMP_TRANSFER_BOOSTING
	
	var static_heat_transfer = player_current_static * TEMP_TRANSFER_STATIC_FACTOR
	heat_transfer += static_heat_transfer
	
	heat_transfer = round(heat_transfer * 1000.0) / 1000.0
	
	current_heat_transfer = heat_transfer
	update_temp(heat_transfer)


# ---- HEATER ----
var is_heater_on = false
var HEATER_ENERGY_COST = 10
var TEMP_TRANSFER_HEATER_MAX: float = 1.0
var heater_power: float = 0.5

func update_heater_state(new_state: bool) -> void:
	if is_heater_on == new_state:
		return
	
	is_heater_on = new_state

func update_heater_power(new_value: float) -> void:
	heater_power = new_value
	
	if heater_power > 1:
		heater_power = 1
	elif heater_power < 0:
		heater_power = 0

func calculate_heater_heat_transfer() -> float:
	var heat_transfer: float = TEMP_TRANSFER_HEATER_MAX * heater_power
	
	return heat_transfer

# ---- PROGRESSION ----
func progress(new_mode: int) -> void:
	third_eye.mode = new_mode
	
	if new_mode == 1:
		enable_third_eye()
		shop_third_eye_ui.hide()
	elif new_mode == 2:
		$progress/point_1_area_2d.queue_free()
		activate_area_1()
		follow_the_eye_ui.show_message()
		$progress/eye_point_1.hide()
	elif new_mode == 3:
		secret_success_sound.play()
		follow_the_eye_ui.show_message()
		$progress/eye_point_3.show()
		update_static(3000)
	elif new_mode == 4:
		$progress/point_3_area_2d.queue_free()
		activate_area_2()
		follow_the_eye_ui.show_message()
		$progress/eye_point_3.hide()
	elif new_mode == 5:
		secret_success_sound.play()
		follow_the_eye_ui.show_message()
		$progress/eye_point_5.show()
		update_static(3500)
	elif new_mode == 6:
		$progress/point_5_area_2d.queue_free()
		activate_area_3()
		follow_the_eye_ui.show_message()
		$progress/eye_point_5.hide()


# MODE 0
func _on_get_eye_button_pressed() -> void:
	progress(1)

func enable_third_eye() -> void:
	have_third_eye = true
	secret_success_sound.play()
	third_eye.show()
	follow_the_eye_ui.show_message()
	$progress/eye_point_1.show()

# MODE 1
func _on_point_1_area_2d_area_entered(area: Area2D) -> void:
	if area.name == "player_area_2D" and third_eye.mode == 1:
		progress(2)

func activate_area_1() -> void:
	secret_success_sound.play()
	area_1_door.queue_free()
	area_1.show()

# MODE 2
var can_interact_with_statue_p2 = false

func _on_interaction_area_2d_others_area_entered(area: Area2D) -> void:
	if area.name == "point_2_area_2d" and third_eye.mode == 2:
		can_interact_with_statue_p2 = true
		player_alert_0.show()
	
	if area.name == "point_4_area_2d" and third_eye.mode == 4:
		can_interact_with_statue_p4 = true
		player_alert_0.show()

func _on_interaction_area_2d_others_area_exited(area: Area2D) -> void:
	if area.name == "point_2_area_2d":
		can_interact_with_statue_p2 = false
		player_alert_0.hide()
	
	if area.name == "point_4_area_2d":
		can_interact_with_statue_p4 = false
		player_alert_0.hide()

# MODE 3
func _on_point_3_area_2d_area_entered(area: Area2D) -> void:
	if area.name == "player_area_2D" and third_eye.mode == 3:
		progress(4)

func activate_area_2() -> void:
	secret_success_sound.play()
	area_2_door.queue_free()
	area_2.show()

# MODE 4
var can_interact_with_statue_p4 = false

# MODE 5
func _on_point_5_area_2d_area_entered(area: Area2D) -> void:
	if area.name == "player_area_2D" and third_eye.mode == 5:
		progress(6)

func activate_area_3() -> void:
	secret_success_sound.play()
	area_3_door.queue_free()
	area_3.show()

# MODE 6
func _on_final_sphere_area_2d_area_entered(_area: Area2D) -> void:
	update_pause(true)
	$ending_screen.show()


# ---- INSTRUCTIONS ----
func show_instructions():
	instructions_ui.show()
	update_pause(true)

func hide_instructions():
	instructions_ui.hide()
	update_pause(false)

func _on_open_instructions_btn_pressed() -> void:
	show_instructions()


# ---- TOOLS ----
func get_all_static_nodes(parent: Node) -> Array:
	var matching_nodes = []
	
	# CHECK CURRENT NODE
	if parent.has_meta('type') and parent.get_meta('type') == 'STATIC_NODE':
		matching_nodes.append(parent)
	
	# CHECK CHILDREN RECURSIVE
	for child in parent.get_children():
# 		Ensure the child is a Node (in case of odd node types)
		if child is Node: 
			matching_nodes += get_all_static_nodes(child)
	
	return matching_nodes
