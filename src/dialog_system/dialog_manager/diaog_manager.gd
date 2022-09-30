extends Node

signal start_dialog
signal dialog_finished

onready var audio_player = $AudioStreamPlayer

var dialog_elements = []
var is_playing = false setget set_is_playing


func _ready():
	pass


func _process(_delta):
	if is_playing and Input.is_action_just_pressed("interact"):
		stop_dialog()


func play_dialog_set(dialog_array: Array) -> void:
	for element in dialog_array:
		set_is_playing(true)
		play_dialog(element)
		yield(audio_player, "finished")
		set_is_playing(false)


func play_dialog(dialog: Dialog) -> void:
	# Make sure the audio player is ready to playback
	audio_player.stop()
	# Get the text and trigger the UI change
	var dialog_text = get_dialog_text(dialog.text_filepath)
	emit_signal("start_dialog", dialog.portrait, dialog_text[0])
	# Trigger the audio and wait for the dialog to finish
	audio_player.stream = dialog.audio
	if audio_player.stream:
		audio_player.play()
		yield(audio_player, "finished")
		emit_signal("dialog_finished")


func stop_dialog() -> void:
	audio_player.stop()
	audio_player.stream = null
	emit_signal("dialog_finished")


func get_dialog_text(filepath: String):
	# Dialog is stored in the JSON format like so
	# [{
	#   "character": {CHARACTER},
	#	"dialog": [
	#		"text goes here"
	#		"more text goes here"
	#		[
	# }]
	
	# Read the file
	var data_file = File.new()
	if data_file.open(filepath, File.READ) != OK:
		return
	# Extract the text
	var data_text = data_file.get_as_text()
	data_file.close()
	# Parse the JSON
	var data_parse = JSON.parse(data_text)
	if data_parse.error != OK:
		return
	var data = data_parse.result
	
	return data["dialog"]
	

func set_is_playing(value):
	is_playing = value
	if not is_playing:
		stop_dialog()
