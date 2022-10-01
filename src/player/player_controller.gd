extends KinematicBody
class_name PlayerController

onready var mesh = $MeshInstance
onready var collider = $BodyCollider
onready var foot_collider = $FootCollider
onready var tween = $Tween
onready var audio_player = $AudioStreamPlayer3D

onready var hue = 0

# Array of all things that should rotate
onready var rotateable = [
	collider,
	$MeshInstance
]

onready var camera_pivot = $CameraPivot
onready var camera = camera_pivot.camera

onready var state_machine = $StateMachine
onready var movement_state = $StateMachine/Movement

onready var debug_menu = $UI/DebugMenu

const SNAP_DIRECTION = Vector3.DOWN
const SNAP_LENGTH = 32


func _ready():
	debug_menu.floaty_slider.connect("value_changed", self, "set_inertia")
	debug_menu.floaty_slider.value = movement_state.inertia
	debug_menu.speed_slider.connect("value_changed", self, "set_speed")
	debug_menu.speed_slider.value = movement_state.move_speed


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT && event.pressed:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta) -> void:
	hue += 0.001
	if hue > 1:
		hue = 0
	var new_colour = Color.from_hsv(hue, 1, 1, 1)
	mesh.get_surface_material(0).albedo_color = new_colour


func set_inertia(value):
	movement_state.inertia = value


func set_speed(value):
	movement_state.move_speed = value
