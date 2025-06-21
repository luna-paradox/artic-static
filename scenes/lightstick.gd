extends CharacterBody2D
class_name Lightstick

@onready var sprite_base = $sprites/sprite_base
@onready var sprite_base_under = $sprites/sprite_base_under
@onready var sprite_stick = $sprites/sprite_stick
@onready var light = $light

@export var color: Color = Color("#d6d327")

# ---- INITIALIZE ----
func _ready() -> void:
	sprite_base.show()
	sprite_base_under.show()
	sprite_stick.show()
	sprite_stick.self_modulate = color
	light.color = color

# ---- SHOOT IT ----
var SHOOTING: bool = true
var DIRECTION: Vector2 = Vector2.RIGHT 
var SPEED: float = 2000.0 

var EXTRA_DISTANCE_SHOOTING: bool = false
var EXTRA_DISTANCE: float = 8

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
