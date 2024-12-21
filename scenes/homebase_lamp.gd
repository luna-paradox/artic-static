extends Node2D

@export var ROTATE_LAMP = true
@export var DIRECTION = 1
@export var WAIT_TIME = 2.0
@export var ROTATION_SPEED = 0.08
@export var ROTATION_DEGREES = 20

var base_rotation = 0
var pause = 0

func _ready() -> void:
	base_rotation = rotation_degrees

func _process(delta: float) -> void:
	if !ROTATE_LAMP:
		return
	
	if pause == 0:
		rotate(ROTATION_SPEED * delta * DIRECTION)
	
	if base_rotation - rotation_degrees <= -ROTATION_DEGREES:
		if pause > WAIT_TIME:
			DIRECTION = -1
			pause = 0
		else:
			pause += delta
	if base_rotation - rotation_degrees >= ROTATION_DEGREES:
		if pause > WAIT_TIME:
			DIRECTION = 1
			pause = 0
		else:
			pause += delta
