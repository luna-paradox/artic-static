extends Control

@onready var pupil = $pupil
@onready var eye_center = $center_eye
var RADIUS = 18

@export var eye_point_1: Node2D
@export var eye_point_2: Node2D
@export var eye_point_3: Node2D
@export var eye_point_4: Node2D
@export var eye_point_5: Node2D
@export var eye_point_6: Node2D
@export var player: CharacterBody2D

var mode = 0

func _process(_delta: float) -> void:
	if mode == 0:
		return
	elif mode == 1:
		pupil_follow_point(eye_point_1)
	elif mode == 2:
		pupil_follow_point(eye_point_2)
	elif mode == 3:
		pupil_follow_point(eye_point_3)
	elif mode == 4:
		pupil_follow_point(eye_point_4)
	elif mode == 5:
		pupil_follow_point(eye_point_5)
	elif mode == 6:
		pupil_follow_point(eye_point_6)


func pupil_follow_point(point: Node2D) -> void:
	
	var angle = player.get_angle_to(point.global_position)
	if player.get_transform().get_scale().y != 1:
		angle = angle + deg_to_rad(180)
		pass
	
	var practical_radius = RADIUS
	var dist = player.global_position.distance_to(point.global_position)
	if dist < 500:
		practical_radius = RADIUS * dist / 100 / 5
	
	var pupil_x = eye_center.global_position.x + practical_radius * cos(angle)
	var pupil_y = eye_center.global_position.y + practical_radius * sin(angle)
	
	pupil.global_position = Vector2(pupil_x, pupil_y)
