extends Node2D
@onready var interaction_collider = $interaction_area/collider
@onready var light = $light

@onready var spr_ooze_s = $static_ooze_sprites/static_ooze_s
@onready var spr_ooze_m = $static_ooze_sprites/static_ooze_m
@onready var spr_ooze_l = $static_ooze_sprites/static_ooze_l
@onready var spr_ooze_xl = $static_ooze_sprites/static_ooze_xl

@export var random_static_variance: float = 0.1
@export var is_testing: bool = false

@export var max_static_amount: float = 300.0
var current_static_amount: float = 300.0

enum NODE_SIZE { x, S, M, L, XL } 
@export var current_node_size: NODE_SIZE = NODE_SIZE.x

var enabled = true

var original_light_pos: Vector2 = Vector2.ZERO
var hidden_light_pos: Vector2 = Vector2(99999999, 99999999)

func _ready() -> void:
	original_light_pos = light.position
	spr_ooze_s.hide()
	spr_ooze_m.hide()
	spr_ooze_l.hide()
	spr_ooze_xl.hide()
	
	set_max_static()
	update_sprite()
	
	original_light_strenght = light.energy
	update_light_energy()
	
	set_meta('type', 'STATIC_NODE')

func set_max_static():
	if random_static_variance == 0.0:
		current_static_amount = max_static_amount
		return
	
	
	var variance_int: int = floor(random_static_variance * 100.0)
	var r = randi() % variance_int + 1
	r = r/100.0
	r = 1 - r
	max_static_amount = max_static_amount * r
	
	if is_testing:
		print('NEW max_static_amount: ' + str(max_static_amount))
	
	current_static_amount = max_static_amount
	

#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("1_debug"):
		#reset()

#func _process(delta: float) -> void:
	#consume(delta * 100)

# Consume the node. The delta_rate should be low to be used from _process
# It returns if the node is depleted or not
func consume(delta_rate: float) -> bool:
	current_static_amount -= delta_rate
	
	if current_static_amount > max_static_amount:
		current_static_amount = max_static_amount
	elif current_static_amount < 0:
		current_static_amount = 0
	
	update_sprite()
	update_light_energy()
	
	var is_depleted = current_static_amount <= 0
	if is_depleted:
		disable()
	
	return is_depleted

func disable() -> void:
	current_static_amount = 0
	interaction_collider.disabled = true
	update_sprite()
	
	light.energy = 0
	light.position = hidden_light_pos
	
	enabled = false

var original_light_strenght: float

func reset() -> void:
	set_max_static()
	current_static_amount = max_static_amount
	interaction_collider.disabled = false
	update_sprite()
	
	light.position = original_light_pos
	update_light_energy()
	
	enabled = true

func update_sprite() -> void:
	var last_node_size = current_node_size
	
	if current_static_amount >= 550:
		current_node_size = NODE_SIZE.XL
	elif current_static_amount >= 350:
		current_node_size = NODE_SIZE.L
	elif current_static_amount >= 200:
		current_node_size = NODE_SIZE.M
	elif current_static_amount > 0:
		current_node_size = NODE_SIZE.S
	else:
		current_node_size = NODE_SIZE.x
	
	if last_node_size == current_node_size:
		return
	
	if is_testing:
		print('CHANGE NODE SIZE')
		print('static_amount: ' + str(current_static_amount))
		print('node_size: ' + str(current_node_size))
	
	spr_ooze_s.hide()
	spr_ooze_m.hide()
	spr_ooze_l.hide()
	spr_ooze_xl.hide()
	
	match current_node_size:
		NODE_SIZE.XL:
			spr_ooze_xl.show()
		NODE_SIZE.L:
			spr_ooze_l.show()
		NODE_SIZE.M:
			spr_ooze_m.show()
		NODE_SIZE.S:
			spr_ooze_s.show()

func update_light_energy() -> void:
	var ratio: float = current_static_amount / 600
	if ratio < 0.0:
		ratio = 0.0
	
	light.energy = original_light_strenght * ratio
