extends CanvasLayer

@onready var main_dialog_box = $container/external_container/main_container/dialog_box_mcont/main_dialog_box

# Array with all the dialog lines loaded
var all_dialog = []
# Current position in the all_dialog array
var current_dialog_index = 0

var dialog_db = {
	"test_dialog": {
		"route": "res://dialogs/test.csv"
	}
}

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("1_debug"):
		load_next_line()
	elif event.is_action_pressed("2_debug"):
		load_dialog(dialog_db.test_dialog.route)


# ------ CONTROLLER FUNCTIONS --------

func load_dialog(route: String) -> void:
	reset_dialog_box()
	var data = load(route)
	
	for line in data.records:
		var text = line[line.keys()[3]]
		var speaker_id = line[line.keys()[0]]
		
		var chat_name = '[b]' + get_chat_name(speaker_id) + '[/b]'
		var new_dialog =  chat_name + ':' + text
		
		new_dialog = color_wrap_text(new_dialog, speaker_id)
		
		all_dialog.push_back(new_dialog + "\n")
	
	current_state = states.TALKING
	self.show()
	load_next_line()

func load_next_line() -> void:
	if current_state != states.TALKING:
		print('NO MORE DIALOG')
		return
	
	if current_dialog_index >= all_dialog.size():
		current_state = states.INNACTIVE
		self.hide()
		return
	
	main_dialog_box.text = main_dialog_box.text + all_dialog[current_dialog_index]
	current_dialog_index += 1

func reset_dialog_box() -> void:
	all_dialog = []
	current_dialog_index = 0
	main_dialog_box.text = ''
	current_state = states.INNACTIVE


# ------ STATE MACHINE --------

enum states { PAUSE, INNACTIVE, TALKING }
var current_state = states.PAUSE


# ------ UTILITIES --------

func get_chat_name(speaker_id: String) -> String:
	
	var chat_name = speaker_metadata[speaker_id].chat_name
	return chat_name

func color_wrap_text(original_text: String, speaker_id: String) -> String:
	
	var color = speaker_metadata[speaker_id].color
	return "[color=" + color + "]" + original_text + "[/color]" 

var speaker_metadata = {
	"E": {
		"color": "purple",
		"chat_name": "Emma",
	},
	"C": {
		"color": "yellow",
		"chat_name": "Camila",
	},
}
