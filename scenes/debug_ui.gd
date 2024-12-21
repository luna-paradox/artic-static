extends CanvasLayer

var main_controller: MainController

@export var DELTA_HP: int = 20
@export var DELTA_ENERGY: int = 200
@export var DELTA_STATIC: int = 400

func _ready() -> void:
	main_controller = get_parent()


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
