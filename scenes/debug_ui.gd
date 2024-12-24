extends CanvasLayer

@onready var speedometer = $container/speedometer
@onready var hp_label = $container/hp_label
@onready var energy_label = $container/energy_label
@onready var static_label = $container/static_label
@onready var temp_label = $container/temp
@onready var heater_label = $container/heater_label
@onready var heat_transfer_label = $container/heat_transfer_label
@onready var freq_label = $container/freq_controls/label_cont/label

@export var DELTA_HP: int = 20
@export var DELTA_ENERGY: int = 200
@export var DELTA_STATIC: int = 400
@export var DELTA_TEMP: float = 0.1

@onready var main_controller: MainController = $".."
@onready var player: Player = $"../player"


func _process(_delta: float) -> void:
	update_speedometer()
	if main_controller:
		hp_label.text = str(round(main_controller.current_hp * 100.0)/100.0)
		static_label.text = str(round(main_controller.player_current_static))
		heater_label.text = str(round(main_controller.heater_power * 100.0)/100.0)
		
		heat_transfer_label.text = str(main_controller.current_heat_transfer)
		$container/heater_slider.value = main_controller.heater_power
		
		var current_freq = main_controller.get_current_sonar_freq()
		var freq_string = main_controller.SONAR_FREQ.keys()[current_freq.id]
		freq_label.text = freq_string
		
		update_energy()
		update_temperature()


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

func update_energy() -> void:
	var energy = main_controller.current_energy
	var string = str(energy)
	
	if energy - floor(energy) == 0:
		string += ".00"
	elif energy*10 - floor(energy*10) == 0:
		string += "0"
	
	energy_label.text = string


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

# ---- TEMPERATURE ----
func update_temperature() -> void:
	var temp = main_controller.current_temp
	var temp_str = str(temp)
	
	if temp - floor(temp) == 0:
		temp_str += ".00"
	elif temp*10 - floor(temp*10) == 0:
		temp_str += "0"
	if temp < 10:
		temp_str = " " + temp_str
	
	temp_label.text = temp_str + "°C"

func _on_more_temp_pressed() -> void:
	if Input.is_key_pressed(KEY_ALT):
		main_controller.update_temp(DELTA_TEMP * 10)
	else:
		main_controller.update_temp(DELTA_TEMP)

func _on_less_temp_pressed() -> void:
	if Input.is_key_pressed(KEY_ALT):
		main_controller.update_temp(-DELTA_TEMP * 10)
	else:
		main_controller.update_temp(-DELTA_TEMP)


# ---- HEATER ----
func _on_heater_slider_value_changed(value: float) -> void:
	main_controller.update_heater_power(value)


# ---- SONAR FREQ ----
func _on_next_freq_pressed() -> void:
	main_controller.update_sonar_freq(1)

func _on_prev_freq_pressed() -> void:
	main_controller.update_sonar_freq(-1)
