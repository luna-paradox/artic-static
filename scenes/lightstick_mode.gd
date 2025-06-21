extends Node2D

@onready var player: Player = get_parent()

# Distance between the dots
const DOT_SPACING: float = 10.0
const LINE_LENGTH: float = 300.0
const DOT_RADIUS: float = 2.0

var COLOR: Color = Color(0.0, 1.0, 0.0, 1)

func _process(_delta: float) -> void:
	if !self.visible:
		return
	queue_redraw()

func _draw() -> void:
	if !player:
		return
	
	draw_aim_line()


func draw_aim_line() -> void:
	var origin: Vector2 = to_local(player.global_position)
	var mouse_pos: Vector2 = get_local_mouse_position()
	var dir: Vector2 = (mouse_pos - origin).normalized()
	#var distance: float = min(origin.distance_to(mouse_pos), LINE_LENGTH)
	var distance: float = LINE_LENGTH

	for i in range(0, int(distance / DOT_SPACING)):
		var t: float = i * DOT_SPACING / LINE_LENGTH  # 0.0 to 1.0
		var pos: Vector2 = origin + dir * i * DOT_SPACING
		var alpha: float = 1.0 - t  # fade out
		COLOR.a = alpha
		draw_circle(pos, DOT_RADIUS, COLOR)

func get_aim_direction() -> Vector2:
	var origin: Vector2 = to_local(player.global_position)
	var mouse_pos: Vector2 = get_local_mouse_position()
	var dir: Vector2 = (mouse_pos - origin).normalized()
	
	return dir
