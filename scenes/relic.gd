extends Node2D

@onready var sprites = $sprites
var sprites_material: Material

@onready var all_sprites = [
	$sprites/brain_bg,
	$sprites/brain/brain_2,
	$sprites/brain/brain_1,
	$sprites/brain/brain_0,
	$sprites/base,
	$sprites/buttons,
	$sprites/circle_screen,
	$sprites/square_screen,
	$sprites/tumor,
]

@onready var spr_circle_screen = $sprites/circle_screen
@onready var spr_tumor = $sprites/tumor
@onready var spr_brain = $sprites/brain

# If the relic is being scanned right now
var scanning_enabled: bool = false
var shader_scanner_time: float = 0.0

var scanned_percentage: float = 0.0
# if the relic was scanned completely
var was_scanned: bool = false

func reset():
	scanning_enabled = true
	shader_scanner_time = 0.0
	scanned_percentage = 0.0
	was_scanned = false

func scan(delta: float):
	scanned_percentage += delta
	#print('SCANNING: ' + str(scanned_percentage))
	if scanned_percentage < 100.0:
		return
	was_scanned = true

func update_scanning(new_state: bool) -> void:
	for sprite in all_sprites:
		sprite.material.set_shader_parameter("enabled", new_state)
	
	spr_circle_screen.toggle_wave_2(new_state)
	spr_tumor.toogle_mode(new_state)
	spr_brain.toggle_mode(new_state)
	
	scanning_enabled = new_state
	if new_state:
		shader_scanner_time = 0.0

func _process(delta):
	if scanning_enabled:
		shader_scanner_time += delta
		run_shader()

func run_shader() -> void:
	for sprite in all_sprites:
		sprite.material.set_shader_parameter("custom_time", shader_scanner_time)
