extends CharacterBody2D

@onready var sprite = $sprite
@onready var light_container = $light_container
@onready var interaction_area_2d = $interaction_area_2d
@onready var motor_sound = $audio/motor_sound
@onready var damage_sound = $audio/damage_sound

var main_controller: MainController
var pause: bool = true

@export var ACCELERATION: int = 200
@export var DECELERATION: int = 100
@export var MAX_SPEED: int = 400


var sonar_timer: Timer
@onready var virtual_position: Node2D = $"../virtual_player_pos"
@onready var sonar: Node2D = $"../virtual_player_pos/sonar"
@onready var sonar_sprite: Node2D = $"../virtual_player_pos/sonar/sprite"

func _ready() -> void:
	sonar_timer = Timer.new()
	sonar_timer.wait_time = 2
	sonar_timer.one_shot = true
	sonar_timer.timeout.connect(hide_sonnar)
	add_child(sonar_timer)

var is_sonar_enabled = false
var target_node: Node2D

func activate_sonar(new_target_node: Node2D) -> void:
	is_sonar_enabled = true
	target_node = new_target_node
	
	if !sonar.visible:
		sonar.show()
		sonar_timer.start()

func hide_sonnar() -> void:
	sonar.hide()
	is_sonar_enabled = false


func _process(_delta: float) -> void:
	if is_sonar_enabled:
		var new_angle = virtual_position.get_angle_to(target_node.global_position)
		new_angle += deg_to_rad(90)
		sonar.rotation = new_angle
		
		var new_alpha = sonar_timer.time_left / sonar_timer.wait_time
		sonar_sprite.self_modulate.a = new_alpha


func _input(event: InputEvent) -> void:
	if pause:
		return
	
	if event.is_action_pressed("turn_sub"):
		self.scale.x *= -1


func _physics_process(delta):
	if pause:
		return
	
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
	if collision:
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


func init(new_acceleration: int, new_deceleration: int, new_max_peed: int):
	ACCELERATION = new_acceleration
	DECELERATION = new_deceleration
	MAX_SPEED = new_max_peed


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
