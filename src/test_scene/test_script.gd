extends Spatial

onready var dialog_handler = $UI/NPCDialog
onready var test_dialog_1 = load("res://assets/dialog/test/00_1_test_dialog.tres")
onready var test_dialog_2 = load("res://assets/dialog/test/00_2_test_dialog.tres")
onready var test_dialog_3 = load("res://assets/dialog/test/00_3_test_dialog.tres")



func _process(_delta):
	if Input.is_action_just_pressed("testing"):
		dialog_handler.dialog_manager.play_dialog_set([test_dialog_1, test_dialog_2, test_dialog_3])
