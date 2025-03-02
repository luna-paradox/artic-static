extends Node2D

@onready var particles = $particles
@onready var collider = $area_2d/collider

@export var current_strenght = 1
@export var direction = Vector2.UP

@export var enable_auto_gravity = true
@export var enable_auto_particle_amount = true
@export var enable_auto_particle_lifetime = true

func _ready() -> void:
	particles.process_material = particles.process_material.duplicate()
	
	update_gravity()
	update_particle_amount()
	update_particle_lifetime()


func _input(event: InputEvent) -> void:
	if event.is_action("1_debug"):
		pass


func update_gravity() -> void:
	if !enable_auto_gravity:
		return
	
	# CONFIGURE SPEED
	var particle_speed = current_strenght * 3
	var particle_direction_2d = direction.normalized() * particle_speed
	
	# CONFIGURE LIFETIME
	var particle_direction_3d = Vector3(particle_direction_2d.x, particle_direction_2d.y, 0)
	particles.process_material.gravity = particle_direction_3d

func update_particle_amount() -> void:
	if !enable_auto_particle_amount:
		return
	
	var shape: RectangleShape2D = collider.shape
	var area = shape.size.x * shape.size.y * scale.x * scale.y
	
	# Area: 800 x 800 = 640.000 pixels^2
	# Amount: 40 particles
	# 0,0000625 particles/pixels^2
	var ratio: float = 100.0 / 640000.0
	var new_amount: int = ratio * area
	particles.amount = new_amount

func update_particle_lifetime() -> void:
	if !enable_auto_particle_lifetime:
		return
	
	# current_strenght = 100 -> lifetime 1.2
	# current_strenght = 500 -> lifetime 0.7
	# lifetime = (-current_strenght / 800) + 1.075
	
	var new_lifetime = (-current_strenght / 800.0) + 1.325
	particles.lifetime = new_lifetime
	
	#print(str(new_lifetime))
