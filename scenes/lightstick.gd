extends CharacterBody2D
class_name Lightstick

@onready var sprite_base = $sprites/sprite_base
@onready var sprite_base_under = $sprites/sprite_base_under
@onready var sprite_stick = $sprites/sprite_stick
@onready var light = $light
#@onready var light_texture = $light.texture as GradientTexture2D
var light_texture: GradientTexture2D

@export var color: Color = Color("#d6d327")
var light_mod_color: Color = color
var stick_mod_color: Color = color
var stick_s_init = stick_mod_color.s
var stick_s_end = stick_mod_color.s * 0.5
var stick_v_init = stick_mod_color.v
var stick_v_end = stick_mod_color.v * 0.5

@onready var glow_out_timer: Timer = $glow_out_timer
var glowing: bool = true

# ---- INITIALIZE ----
func _ready() -> void:
	sprite_base.show()
	sprite_base_under.show()
	sprite_stick.show()
	sprite_stick.self_modulate = color
	glow_out_timer.timeout.connect(_on_glow_out_timer_timeout)
	
	# Duplicate textrue so this instance has its own copy
	# otherwise when dimming the texture it affects all instances
	# of glowsticks
	var unique_texture = light.texture.duplicate(true)
	light.texture = unique_texture
	light_texture = light.texture as GradientTexture2D
	light_texture.gradient.set_color(0, color)
	

# ---- SHOOT IT ----
var SHOOTING: bool = true
var DIRECTION: Vector2 = Vector2.RIGHT 
var SPEED: float = 2000.0 

var EXTRA_DISTANCE_SHOOTING: bool = false
var EXTRA_DISTANCE: float = 8

func _process(_delta: float) -> void:
	if glowing:
		# it stops glowing when the timer is 70% in
		var progress_percentage: float = glow_out_timer.time_left / glow_out_timer.wait_time
		if progress_percentage > 0.3:
			return
		
		var new_energy_ratio: float = progress_percentage / 0.3
		
		# make it dimmer by making the texture more transparent
		# that way it doesnt have the "shadow" effect on other sources
		#if new_energy_ratio > 0.05:
		light_mod_color.a = new_energy_ratio
		light_texture.gradient.set_color(0, light_mod_color)
		
		# make the stick more grey by updating the s and v hsv values
		var new_s = (stick_s_init - stick_s_end) * new_energy_ratio + stick_s_end
		var new_v = (stick_v_init - stick_v_end) * new_energy_ratio + stick_v_end
		stick_mod_color.s = new_s
		stick_mod_color.v = new_v
		sprite_stick.self_modulate = stick_mod_color

func _physics_process(delta: float) -> void:
	if !SHOOTING:
		return
	
	if EXTRA_DISTANCE_SHOOTING:
		if EXTRA_DISTANCE > 0.0:
			var step = min(EXTRA_DISTANCE, SPEED * delta)
			position += DIRECTION.normalized() * step
			EXTRA_DISTANCE -= step
		else:
			SHOOTING = false
			EXTRA_DISTANCE_SHOOTING = false
			sprite_base.hide()
			sprite_base_under.show()
		return
	
	velocity = DIRECTION.normalized() * SPEED
	var collided_wall = move_and_collide(velocity * delta)
	
	if collided_wall:
		EXTRA_DISTANCE_SHOOTING = true

func _on_glow_out_timer_timeout() -> void:
	#light.queue_free()
	glowing = false
