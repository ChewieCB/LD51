extends Spatial

export (NodePath) var camera_target
onready var current_target = get_node(camera_target)
onready var camera = $ClippedCamera

export (float, 0.1, 25.0) var look_sensitivity = 15.0
export var min_look_angle = -35.0
export var max_look_angle = 85.0

var camera_rotation = Vector3.ZERO
var camera_lerp_goal = Vector3.ZERO

var mouse_delta = Vector2.ZERO
var is_using_controller = false


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	self.rotation.y = current_target.rotation.y

func _unhandled_input(event):
	# Get pitch and yaw values from relative mouse/joystick movement
	if event is InputEventMouseMotion:
		is_using_controller = false
		mouse_delta = event.relative
		if not GlobalFlags.CAMERA_INVERT_X:
			mouse_delta.x *= -1
		if not GlobalFlags.CAMERA_INVERT_Y:
			mouse_delta.y *= -1
	elif event is InputEventJoypadMotion:
		is_using_controller = true

func _physics_process(_delta):
	self.global_transform.origin = current_target.global_transform.origin
	# TODO - camera colliders

func _process(delta):
	if not GlobalFlags.CAMERA_CONTROLS_ACTIVE:
		return
	
	if is_using_controller:
		mouse_delta = Vector2(
			Input.get_vector(
				"camera_left", "camera_right",
				"camera_up", "camera_down"
			)
		) * 10
		
		# Camera inversions
		if not GlobalFlags.CAMERA_INVERT_X:
			mouse_delta.x *= -1
		if GlobalFlags.CAMERA_INVERT_Y:
			mouse_delta.y *= -1
	
	var yaw_dir = mouse_delta.x
	var pitch_dir = mouse_delta.y
	
	var _is_player_moving_camera = (mouse_delta != Vector2.ZERO)

	# Rotate the camera pivot accordingly
	camera_rotation = Vector3(pitch_dir, yaw_dir, 0) * look_sensitivity * delta
	# Convert the vector from degrees to radians
	camera_rotation *= PI/180
	rotation.y += camera_rotation.y

	rotation.x += camera_rotation.x
	rotation.x = clamp(rotation.x, min_look_angle, max_look_angle)
	
	mouse_delta = Vector2.ZERO
