extends Control

@onready var bg = $bg
@onready var after_image_bar = $after_image_bar
@onready var progress_bar = $progress_bar

@export var level_1_color = Color8(139, 255, 96) # UP TO 70%
@export var level_2_color = Color8(246, 255, 96) # UP TO 30%
@export var level_3_color = Color8(255, 185, 96)

@export var after_image_color = Color8(255, 71, 71)

@export var background_color = Color8(190, 215, 215)
@export var label_color = Color8(60, 60, 60)

@export var level_1_min = 0.7
@export var level_2_min = 0.3

@export var use_after_image = true
@export var tween_on_fill = true
@export var tween_time_on_fill = 0.1
@export var tween_on_deplete = true
@export var tween_time_on_deplete = 0.1

var max_value = 100
var current_value = 50
var current_per: float = 0.0


func _ready():
	if !use_after_image:
		after_image_bar.hide()
		
	progress_bar.color = level_1_color
	after_image_bar.color = after_image_color
	bg.color = background_color
	
	update_bar(max_value)

# INIT 
func init(new_max_value: int, initial_value: int = -1) -> void:
	max_value = new_max_value
	
	if initial_value == -1:
		update_bar(new_max_value)
	else:
		update_bar(initial_value)

# UPDATE BAR
func update_bar(new_value):
	# LIMITERS
	if (new_value < 0):
		current_value = 0
	else:
		current_value = new_value
	
	current_per = float(current_value) / float(max_value) * (-1)
	
	# UPDATE BAR COLOR
	if (current_per * (-1) > level_1_min):
		progress_bar.color = level_1_color
	elif (current_per * (-1) > level_2_min):
		progress_bar.color = level_2_color
	else:
		progress_bar.color = level_3_color
	
	# UPDATE PROGRES BAR 
	# (object: Object, property: NodePath, final_val: Variant, duration: float)
	if current_per > progress_bar.scale.y && tween_on_fill:
		var tween = create_tween()
		tween.tween_property(
			progress_bar, 
			"scale:y", 
			current_per, 
			tween_time_on_fill
		).from(progress_bar.scale.y).set_trans(Tween.TRANS_SINE)
	elif tween_on_deplete:
		var tween = create_tween()
		tween.tween_property(
			progress_bar, 
			"scale:y", 
			current_per, 
			tween_time_on_deplete
		).from_current().set_trans(Tween.TRANS_SINE)
	else:
		progress_bar.scale.y = current_per;
	
	# UPDATE AFTER IMAGE BAR
	if use_after_image:
		var tween = create_tween()
		tween.tween_property(
			after_image_bar, 
			"scale:y", 
			current_per, 
			0.4
		).from_current().set_trans(Tween.TRANS_SINE)

# FOR DEBUG
#func _input(event: InputEvent) -> void:
	#if (event.is_action_pressed("left")):
		#update_bar(current_value - 50)
	#elif (event.is_action_pressed("bottom")):
		#update_bar(current_value - 20)
	#elif (event.is_action_pressed("top")):
		#update_bar(current_value + 20)
	#elif (event.is_action_pressed("right")):
		#update_bar(current_value + 50)
