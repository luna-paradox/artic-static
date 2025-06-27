extends CharacterBody2D
class_name Player

@onready var sprite = $sprite
@onready var light_container = $light_container
@onready var interaction_area_2d = $areas_2d/interaction_area_2d
@onready var motor_sound = $audio/motor_sound
@onready var damage_sound = $audio/damage_sound
@onready var turbo_sound = $audio/turbo_sound
@onready var central_light = $central_light
@onready var lightstick_mode_ui = $lightstick_mode_ui
@onready var alert_0 = $alert_0

var main_controller: MainController
var pause: bool = true

@onready var virtual_position: Node2D = $"../virtual_player_pos"


# ---- BUILT-IN ----
func _ready() -> void:
	sonar_timer = Timer.new()
	sonar_timer.wait_time = 2
	sonar_timer.one_shot = true
	sonar_timer.timeout.connect(hide_sonnar)
	add_child(sonar_timer)
	
	central_light.show()

func _process(delta: float) -> void:
	if is_sonar_enabled:
		process_sonar()
	
	if !pause:
		control_turbo_volume(delta)

func _physics_process(delta):
	if pause:
		return
	
	# MOVE AND COLLIDE
	var collision = move_vessel(delta)
	crash_vessel(collision)

func update_movement_stats(new_acceleration: int, new_deceleration: int, new_max_peed: int):
	ACCELERATION = new_acceleration
	DECELERATION = new_deceleration
	MAX_SPEED = new_max_peed


# ---- MOVEMENT ----
@export var ACCELERATION: int
@export var DECELERATION: int
@export var MAX_SPEED: int

var current_influence = Vector2.ZERO

func move_vessel(delta: float) -> KinematicCollision2D:
	# GET INPUT
	var direction = Input.get_vector("left", "right", "top", "bottom")
	var practical_current_influence = current_influence
	
	
	# MOVE
	if direction != Vector2.ZERO or practical_current_influence != Vector2.ZERO:
		var final_acceleration = ACCELERATION
		var final_max_speed = MAX_SPEED
		
		# BOOSTING EFFECT
		if is_boosting and direction != Vector2.ZERO:
			final_acceleration *= TURBO_ACCELERATION
			final_max_speed *= TURBO_MAX_SPEED
		
		# COLD MAKE THE SUB SLOWER
		if main_controller.current_temp < 0:
			var temp_index = main_controller.current_temp / -10
			
			final_acceleration *= 1 - 0.5 * temp_index
			final_max_speed *= 1 - 0.5 * temp_index
		
		# APPLY ACCELERATION
		var to_pos = direction * final_max_speed + practical_current_influence
		var delta_pos = final_acceleration * delta
		velocity = velocity.move_toward(to_pos, delta_pos)
		
	else:
		var final_deceleration = DECELERATION * delta
		
		# BOOSTING EFFECT
		if is_boosting:
			final_deceleration *= TURBO_DECELERATION
		
		# WORK LIKE FRICTION
		velocity = velocity.move_toward(Vector2.ZERO, final_deceleration)
	
	
	# SFX: CONTROL MOTOR AUDIO
	control_motor_volume(delta, direction)
	
	# DETECT COLLISION
	var collision = move_and_collide(velocity * delta)
	
	return collision

func crash_vessel(collision: KinematicCollision2D) -> void:
	if !collision:
		return
	
	#BOUNCE
	velocity = velocity.bounce(collision.get_normal()) / 3
	if velocity.length() < 20:
		return
	
	#DAMAGE
	#print(str(velocity.length()))
	var damage = floor(velocity.length() * 0.4)
	main_controller.update_hp(-damage)
	
	# SFX
	if !damage_sound.playing:
		var damage_volume = 1
		if velocity.length() < 100:
			damage_volume = velocity.length() / 100
		damage_sound.volume_db = linear_to_db(damage_volume)
		damage_sound.play()

func flip_vessel() -> void:
	scale.x *= -1
	if scale.x == -1:
		lightstick_mode_ui.scale.x *= -1
		alert_0.scale.x *= -1
	pass

# ---- SONNAR ----
@onready var sonar: Node2D = $"../virtual_player_pos/sonar"
@onready var sonar_sprite: Node2D = $"../virtual_player_pos/sonar/sprite"
var sonar_target_node: Node2D
var is_sonar_enabled = false
var sonar_timer: Timer

func activate_sonar(new_target_node: Node2D) -> void:
	is_sonar_enabled = true
	sonar_target_node = new_target_node
	
	if !sonar.visible:
		sonar.show()
		sonar_timer.start()

func hide_sonnar() -> void:
	sonar.hide()
	is_sonar_enabled = false

func process_sonar() -> void:
	var new_angle = virtual_position.get_angle_to(sonar_target_node.global_position)
	new_angle += deg_to_rad(90)
	sonar.rotation = new_angle
	
	var new_alpha = sonar_timer.time_left / sonar_timer.wait_time
	sonar_sprite.self_modulate.a = new_alpha


# ---- TURBO BOOST ----
@export var TURBO_ACCELERATION: int = 3
@export var TURBO_DECELERATION: int = 7
@export var TURBO_MAX_SPEED: int = 3
var is_boosting: bool = false

func turbo_boost() -> void:
	if is_boosting:
		return
	
	is_boosting = true

func disable_turbo_boost() -> void:
	if !is_boosting:
		return
	
	is_boosting = false

# ---- LIGHTSTICK MODE ----
func update_lightstick_mode_ui(is_on: bool):
	if is_on:
		lightstick_mode_ui.show()
	else:
		lightstick_mode_ui.hide()

func get_lightstick_aim_direction() -> Vector2:
	var res: Vector2 = lightstick_mode_ui.get_aim_direction()
	return res

# ---- PAUSE ----
func update_pause(new_state: bool) -> void:
	pause = new_state
	light_container.pause = new_state
	
	if pause:
		motor_sound.stop()
		
		turbo_sound.volume_db = linear_to_db(0)
		current_turbo_volume = 0
		disable_turbo_boost()


# ---- MOTOR AUDIO ----
var current_motor_volume = 0
var MAX_MOTOR_VOLUME = 1
var MOTOR_AUDIO_FADE_IN_SPEED = 3
var MOTOR_AUDIO_FADE_OUT_SPEED = 3

# Manually tween motor sound volume depending on user input
# I couldn't makem the Tweens work, I hate them :( 
func control_motor_volume(delta: float, direction: Vector2) -> void:
	var speed = direction.length()
	
	if speed > 0 and !motor_sound.playing:
		motor_sound.play()
		motor_sound.volume_db = linear_to_db(0.01)
	elif speed > 0 and motor_sound.playing:
		current_motor_volume += delta * MOTOR_AUDIO_FADE_IN_SPEED
		if current_motor_volume > MAX_MOTOR_VOLUME:
			current_motor_volume = MAX_MOTOR_VOLUME
		motor_sound.volume_db = linear_to_db(current_motor_volume)
	elif speed == 0 and motor_sound.playing:
		current_motor_volume -= delta * MOTOR_AUDIO_FADE_OUT_SPEED
		if current_motor_volume <= 0:
			current_motor_volume = 0
		motor_sound.volume_db = linear_to_db(current_motor_volume)
	
	if db_to_linear(motor_sound.volume_db) <= 0 and motor_sound.playing:
		motor_sound.stop()


# ---- TURBO AUDIO ----
var current_turbo_volume = 0
var MAX_TURBO_VOLUME = 1.5
var TURBO_AUDIO_FADE_IN_SPEED = 4
var TURBO_AUDIO_FADE_OUT_SPEED = 4

# Manually tween boost sound volume depending on user input
# I couldn't makem the Tweens work, I hate them :( 
func control_turbo_volume(delta: float) -> void:
	
	if is_boosting and !turbo_sound.playing:
		turbo_sound.play()
		turbo_sound.volume_db = linear_to_db(0.01)
	elif is_boosting and turbo_sound.playing:
		current_turbo_volume += delta * TURBO_AUDIO_FADE_IN_SPEED
		if current_turbo_volume > MAX_TURBO_VOLUME:
			current_turbo_volume = MAX_TURBO_VOLUME
		turbo_sound.volume_db = linear_to_db(current_turbo_volume)
	elif !is_boosting and turbo_sound.playing:
		current_turbo_volume -= delta * TURBO_AUDIO_FADE_OUT_SPEED
		if current_turbo_volume <= 0:
			current_turbo_volume = 0
		turbo_sound.volume_db = linear_to_db(current_turbo_volume)
	
	if db_to_linear(turbo_sound.volume_db) <= 0 and turbo_sound.playing:
		turbo_sound.stop()


# ---- COLD AREA DETECTION ----

func _on_cold_area_entered(area: Area2D) -> void:
	var cold_area = area.get_parent()
	if !"heat_transfer" in cold_area:
		return
	
	var heat_transfer = cold_area.heat_transfer
	main_controller.cold_areas_heat_transfer += heat_transfer

func _on_cold_area_exited(area: Area2D) -> void:
	var cold_area = area.get_parent()
	if !"heat_transfer" in cold_area:
		return
	
	var heat_transfer = cold_area.heat_transfer
	main_controller.cold_areas_heat_transfer -= heat_transfer


# ---- AREA OF CURRENT DETECTION ----

func _on_area_of_current_detector_area_entered(area: Area2D) -> void:
	var area_of_current = area.get_parent()
	if !"current_strenght" in area_of_current:
		return
	if !"direction" in area_of_current:
		return
	
	var new_current = area_of_current.direction * area_of_current.current_strenght
	
	current_influence += new_current

func _on_area_of_current_detector_area_exited(area: Area2D) -> void:
	var area_of_current = area.get_parent()
	if !"current_strenght" in area_of_current:
		return
	if !"direction" in area_of_current:
		return
	
	var new_current = area_of_current.direction * area_of_current.current_strenght
	current_influence -= new_current


# ---- EVENT COLLIDERS ----

func _on_event_collider_area_entered(area: Area2D) -> void:
	if !"event_id" in area:
		return
	
	main_controller.trigger_event(area.event_id)
	#print("ENTER:" + area.event_id)
	pass


func _on_event_collider_area_exited(area: Area2D) -> void:
	if !"event_id" in area:
		return
	
	#print("EXIT:" + area.event_id)
	pass
