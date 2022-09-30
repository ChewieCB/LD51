extends State
# Parent state for all movement-related states for the Player
# Holds all of the base movement logic
# Child states can override this states's functions or change its properties
# This keeps the logic grouped in one location

# These should be fallback defaults
# TODO: Make these null and raise an exception to indicate bad State extension
#       to better separate movement vars.
export var max_speed = 20
export var move_speed = 20
export var gravity = 0.0
export var jump_impulse = 35
export (float, 0.1, 20.0, 0.1) var rotation_speed_factor := 2.0
export (int, 0, 200) var inertia = 0

var velocity := Vector3.ZERO
var input_direction = Vector3.ZERO
var move_direction = Vector3.ZERO

var camera_pivot = null
var goal_quaternion


func physics_update(delta: float):
	# Debug Reset
	if Input.is_action_pressed("reset"):
		if GlobalFlags.PLAYER_CONTROLS_ACTIVE == true:
			get_tree().reload_current_scene()
	elif Input.is_action_pressed("quit"):
		GlobalFlags.PLAYER_CONTROLS_ACTIVE = true
		get_tree().quit()
	
	# Movement
	if GlobalFlags.PLAYER_CONTROLS_ACTIVE:
		input_direction = get_input_direction()
	else:
		input_direction = Vector3.ZERO
	
	move_direction = calculate_movement_direction(input_direction, delta)
	
	velocity = calculate_velocity(velocity, move_direction, delta)
	velocity = _actor.move_and_slide(velocity, Vector3.UP, true, 4, 0.785398, false)


func get_input_direction() -> Vector3:
	var input_vector := Input.get_vector(
		"move_left", "move_right",
		"move_forward", "move_backward"
	)
	var input_direction := Vector3(
		input_vector.x,
		0,
		input_vector.y
	)
	
	return input_direction


func calculate_movement_direction(input_direction, _delta) -> Vector3:
	var forwards := Vector3.ZERO
	var right := Vector3.ZERO
	
	# We calculate a move direction vector relative to the camera,
	# the basis stores the (right, up, -forwards) vectors of our camera.
	forwards = input_direction.z * _actor.camera.global_transform.basis.z
	right = input_direction.x * _actor.camera.global_transform.basis.x
	move_direction = forwards + right
	
	if move_direction.length() > 1.0:
		move_direction = move_direction.normalized()
		move_direction.y = 0

	# Rotation
	if move_direction != Vector3.ZERO:
		# Get the angle in the y-axis via atan2
		var movement_angle = atan2(move_direction.x, move_direction.z) + PI
		# lerp_angle prevents the flip-flopping between 0 and 360 degrees
		for element in _actor.rotateable:
			element.rotation.y = lerp_angle(
				element.rotation.y,
				movement_angle,
				0.2
			)
	
	return move_direction 


func calculate_velocity(velocity_current: Vector3, _move_direction: Vector3, delta: float):
	var velocity_new = move_direction * move_speed
	if velocity_new.length() > max_speed:
		velocity_new = velocity_new.normalized() * max_speed
#	velocity_new.y = velocity_current.y + gravity * delta
	
	return velocity_new
