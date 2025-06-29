extends Node2D

@onready var light = $light

func _ready() -> void:
	light.show()
