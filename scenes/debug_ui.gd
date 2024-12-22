extends CanvasLayer

@onready var speedometer = $container/speedometer
@onready var hp_label = $container/hp_label
@onready var energy_label = $container/energy_label
@onready var static_label = $container/static_label

@export var DELTA_HP: int = 20
@export var DELTA_ENERGY: int = 200
@export var DELTA_STATIC: int = 400

@onready var main_controller: MainController = $".."
@onready var player: Player = $"../player"


func _process(_delta: float) -> void:
	update_speedometer()
	if main_controller:
		hp_label.text = str(main_controller.current_hp)
		energy_label.text = str(main_controller.current_energy)
		static_label.text = str(main_controller.player_current_static)

# ---- HP ----
func _on_more_hp_btn_pressed() -> void:
	main_controller.update_hp(DELTA_HP)

func _on_less_hp_btn_pressed() -> void:
	main_controller.update_hp(-DELTA_HP)


# ---- ENERGY ----
func _on_more_energy_btn_pressed() -> void:
	main_controller.update_energy(DELTA_ENERGY)

func _on_less_energy_btn_pressed() -> void:
	main_controller.update_energy(-DELTA_ENERGY)


# ---- STATIC ----
func _on_more_static_btn_pressed() -> void:
	main_controller.update_static(DELTA_STATIC)

func _on_less_static_btn_pressed() -> void:
	main_controller.update_static(-DELTA_STATIC)


# ---- SPEEDOMETER ----
func update_speedometer() -> void:
	var speed_raw = player.velocity.length()
	var new_speed = round(speed_raw)
	
	var speed_str = str(new_speed)
	
	while speed_str.length() < 3:
		speed_str = "0" + speed_str
	
	speedometer.text = speed_str
