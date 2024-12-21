extends Camera2D

@onready var bg = $bg

func _ready() -> void:
	bg.show()

func _process(_delta: float) -> void:
	bg.global_position = get_screen_center_position()
	
	bg.scale.x = 1 / zoom.x
	bg.scale.y = 1 / zoom.y
