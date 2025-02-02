extends CanvasLayer

@onready var main_dialog_box = $container/external_container/main_container/dialog_box_mcont/main_dialog_box
@onready var portrait_texture = $container/portrait_cont/image_cont/portrait_texture

# Array with all the dialog lines loaded
var all_dialog = []
# Current position in the all_dialog array
var current_dialog_index = 0

var dialog_db = {
	"test_dialog_0": {
		"route": "res://dialogs/test.csv"
	},
	"test_dialog_1": {
		"route": "res://dialogs/test_2.csv"
	},
}

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("1_debug"):
		print(fast_dialog)
	elif event.is_action_pressed("2_debug"):
		load_dialog(dialog_db.test_dialog_0.route)
	
	if event.is_action_pressed("progress_dialog"):
		if current_state == states.WAITING:
			load_next_line()
		fast_dialog = true
		
	if event.is_action_released("progress_dialog"):
		fast_dialog = false


# ------ CONTROLLER FUNCTIONS --------
func load_dialog(route: String) -> void:
	if current_state != states.INNACTIVE:
		return
	
	reset_dialog_box()
	var data = load(route)
	
	for line in data.records:
		var speaker_id = line[line.keys()[0]]
		var emotion = line[line.keys()[1]]
		var text = line[line.keys()[4]]
		
		var chat_name = '[b]' + get_chat_name(speaker_id) + '[/b]'
		chat_name = color_wrap_text(chat_name + ":", speaker_id)
		
		all_dialog.push_back({
			"speaker_id": speaker_id,
			"chat_name_string": chat_name,
			"new_dialog_string": text,
			"emotion": emotion,
		})
	
	update_state(states.WAITING)
	self.show()
	load_next_line()

var fast_dialog = false
var wait_time = 0.02

func load_next_line() -> void:
	if current_state != states.WAITING:
		print('NO MORE DIALOG')
		return
	
	if current_dialog_index >= all_dialog.size():
		update_state(states.INNACTIVE)
		return

	update_state(states.TALKING)
	
	var current_line = all_dialog[current_dialog_index]
	
	# UPDATE AVATAR
	var route = 'res://assets/portraits/SPR_portrait_'
	route = route + current_line.speaker_id + "_" + current_line.emotion + ".png"
	
	portrait_texture.texture = load(route)
	
	# PRINT FULL NAME
	main_dialog_box.text = main_dialog_box.text + current_line.chat_name_string
	
	# PRINT DIALOG GRADUALLY
	for character in current_line.new_dialog_string:
		main_dialog_box.text = main_dialog_box.text + color_wrap_text(character, current_line.speaker_id)
		
		wait_time = 0.02
		if fast_dialog:
			wait_time = 0.001
		elif character == '.':
			wait_time = 0.15
		
		await get_tree().create_timer(wait_time).timeout
	
	# ADD A LINBE BREAK
	main_dialog_box.text = main_dialog_box.text + '\n'
	
	current_dialog_index += 1
	update_state(states.WAITING)

func reset_dialog_box() -> void:
	all_dialog = []
	current_dialog_index = 0
	main_dialog_box.text = ''
	update_state(states.INNACTIVE)


# ------ STATE MACHINE --------
enum states { TALKING, INNACTIVE, WAITING }
var current_state = states.INNACTIVE

func update_state(new_state: states) -> void:
	if current_state == new_state:
		return
	
	current_state = new_state
	
	if new_state == states.INNACTIVE:
		self.hide()


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
