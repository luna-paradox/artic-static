extends Node

var num_players = 8
var bus = "master"

var available = []  # The available players.
var queue = []  # The queue of sounds to play.


func _ready():
	# Create the pool of AudioStreamPlayer nodes.
	for i in num_players:
		var p = AudioStreamPlayer.new()
		add_child(p)
		available.append(p)
		p.connect("finished", _on_stream_finished)
		p.bus = bus


func _on_stream_finished(stream):
	# When finished playing a stream, make the player available again.
	available.append(stream)


func play(audio_path):
	audio_path = 'res://assets/audio/' + audio_path
	queue.append(audio_path)


func _process(_delta):
	# Play a queued sound if any players are available.
	if queue.size() > 0 and available.size() > 0:
		available[0].stream = load(queue.pop_front())
		available[0].play()
		available.pop_front()

var looping_players: Array[AudioStreamPlayer] = []

func play_loop(audio_path):
	audio_path = 'res://assets/audio/' + audio_path
	
	var new_player = AudioStreamPlayer.new()
	add_child(new_player)
	new_player.connect("finished", _on_stream_finished)
	new_player.bus = bus
	
	new_player.stream = load(audio_path)
	new_player.play()
