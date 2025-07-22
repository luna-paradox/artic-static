extends PanelContainer
class_name UIUpgradeContainer

@onready var line = $line
@export var line_anchor: Node2D
@export var overlay_ui: TextureRect

func _ready() -> void:
	if line_anchor:
		line.points[1] = line_anchor.position - position
	
	#print("LINE POINT")
	#print(line.points[1])
	#print("ANCHOR POSITION")
	#print(line_anchor.position)
	#print("CONTAINER POSITION")
	#print(position)
	#print("CONTAINER GLOBAL POSITION")
	#print(global_position)
