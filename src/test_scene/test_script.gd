extends Spatial

onready var dialog_handler = $UI/NPCDialog
onready var test_dialog_1 = load("res://assets/dialog/test/00_1_test_dialog.tres")
onready var test_dialog_2 = load("res://assets/dialog/test/00_2_test_dialog.tres")
onready var test_dialog_3 = load("res://assets/dialog/test/00_3_test_dialog.tres")

onready var box = $CSGBox
onready var hue = 0

func _physics_process(delta):
    box.rotation += Vector3(0, delta, 0)
    hue += 0.001
    if hue > 1:
        hue = 0
    var new_colour = Color.from_hsv(hue, 1, 1, 1)
    box.material.albedo_color = new_colour


func _process(_delta):
    if Input.is_action_just_pressed("testing"):
        dialog_handler.dialog_manager.play_dialog_set([test_dialog_1, test_dialog_2, test_dialog_3])
