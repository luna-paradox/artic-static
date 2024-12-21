extends CanvasLayer

var timer: Timer

func _ready() -> void:
	timer = Timer.new()
	timer.wait_time = 3
	timer.one_shot = true
	timer.timeout.connect(hide_message)
	add_child(timer)

func show_message():
	show()
	timer.start()

func hide_message():
	hide()
