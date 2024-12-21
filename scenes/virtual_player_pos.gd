extends Node2D

@onready var player: Node2D = $"../player"

func _process(_delta: float) -> void:
	global_position = player.global_position
