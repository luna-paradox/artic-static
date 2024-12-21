extends CharacterBody2D
class_name Player

@onready var sprite = $sprite
@onready var light_container = $light_container
@onready var interaction_area_2d = $interaction_area_2d
@onready var motor_sound = $audio/motor_sound
@onready var damage_sound = $audio/damage_sound

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

func _process(_delta: float) -> void:
	if is_sonar_enabled:
		process_sonar()

func _input(event: InputEvent) -> void:
	if pause:
		return
	
	if event.is_action_pressed("ctrl_action"):
		self.scale.x *= -1

func _physics_process(delta):
	if pause:
		return
	
	# MOVE AND COLLIDE
	var collision = move_vessel(delta)
	crash_vessel(collision)

func init(new_acceleration: int, new_deceleration: int, new_max_peed: int):
	ACCELERATION = new_acceleration
	DECELERATION = new_deceleration
	MAX_SPEED = new_max_peed


# ---- MOVEMENT ----
@export var ACCELERATION: int = 200
@export var DECELERATION: int = 100
@export var MAX_SPEED: int = 400

func move_vessel(delta: float) -> KinematicCollision2D:
	# GET INPUT
	var direction = Input.get_vector("left", "right", "top", "bottom")
	
	# SEA CURRENT
	#if global_position.y > 500:
		#direction += Vector2.RIGHT / 3
	
	if direction != Vector2.ZERO:
		# APPLY ACCELERATION
		velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	else:
		# WORK LIKE FRICTION
		velocity = velocity.move_toward(Vector2.ZERO, DECELERATION * delta)
	
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
@export var TURBO_DECELERATION: int = 5
@export var TURBO_MAX_SPEED: int = 3
var is_boosting: bool = false

var pre_boost_acceleration: int
var pre_boost_deceleration: int
var pre_boost_max_speed: int

func turbo_boost() -> void:
	if is_boosting:
		return
	
	is_boosting = true
	
	pre_boost_acceleration = ACCELERATION
	pre_boost_deceleration = DECELERATION
	pre_boost_max_speed = MAX_SPEED

	ACCELERATION *= TURBO_ACCELERATION
	DECELERATION *= TURBO_DECELERATION
	MAX_SPEED *= TURBO_MAX_SPEED

func disable_turbo_boost() -> void:
	if !is_boosting:
		return
	
	is_boosting = false
	
	ACCELERATION = pre_boost_acceleration
	DECELERATION = pre_boost_deceleration
	MAX_SPEED = pre_boost_max_speed


# ---- PAUSE ----
func update_pause(new_state: bool) -> void:
	pause = new_state
	if pause:
		motor_sound.stop()


# ---- MOTOR AUDIO ----
var current_motor_volume = 0
var MAX_MOTOR_VOLUME = 1
var MOTOR_AUDIO_FADE_IN_SPEED = 3
var MOTOR_AUDIO_FADE_OUT_SPEED = 3

# Manually tween motor sound volume depending on user input
# I couldn't makem the Tweens work, I hate them :( 
func control_motor_volume(delta: float, direction: Vector2) -> void:
	if direction.length() > 0 and !motor_sound.playing:
		motor_sound.play()
		motor_sound.volume_db = linear_to_db(0.01)
	elif direction.length() > 0 and motor_sound.playing:
		current_motor_volume += delta * MOTOR_AUDIO_FADE_IN_SPEED
		if current_motor_volume > MAX_MOTOR_VOLUME:
			current_motor_volume = MAX_MOTOR_VOLUME
		motor_sound.volume_db = linear_to_db(current_motor_volume)
	elif direction.length() == 0 and motor_sound.playing:
		current_motor_volume -= delta * MOTOR_AUDIO_FADE_OUT_SPEED
		if current_motor_volume <= 0:
			current_motor_volume = 0
		motor_sound.volume_db = linear_to_db(current_motor_volume)
	
	if db_to_linear(motor_sound.volume_db) <= 0 and motor_sound.playing:
		motor_sound.stop()
