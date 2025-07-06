extends Node2D

@onready var spr_front: Sprite2D = $brain_0
@onready var spr_brain: Sprite2D = $brain_1
@onready var spr_back: Sprite2D = $brain_2

var spr_brain_base_position: Vector2 # Original position
var spr_back_base_position: Vector2 
var spr_front_base_position: Vector2
var time_passed: float = 0.0 # Accumulated time
var time_mult: float = 1.0

func toggle_mode(is_strong: bool) -> void:
	if is_strong:
		time_mult = 3.0
	else:
		time_mult = 1.0

func _ready() -> void:
	spr_brain_base_position = spr_brain.position
	spr_back_base_position = spr_back.position
	spr_front_base_position = spr_front.position

func _process(delta: float) -> void:
	time_passed += delta * time_mult
	
	move_spr_brain()
	move_spr_back()
	move_spr_front()

func move_spr_brain() -> void:
	# How far it moves up and down
	var amplitude: float = 1.1
	# How fast it oscillates
	var frequency: float = 0.4

	var offset_y = sin(time_passed * frequency * TAU) * amplitude
	spr_brain.position.y = spr_brain_base_position.y + offset_y

func move_spr_back() -> void:
	# How far it moves up and down
	var amplitude: float = 1.1
	# How fast it oscillates
	var frequency: float = 0.3

	var offset_y = sin(time_passed * frequency * TAU) * amplitude
	spr_back.position.y = spr_back_base_position.y + offset_y

func move_spr_front() -> void:
	# How far it moves up and down
	var amplitude: float = 1.1
	# How fast it oscillates
	var frequency: float = 0.35

	var offset_y = sin(time_passed * frequency * TAU) * amplitude
	spr_front.position.y = spr_front_base_position.y + offset_y
