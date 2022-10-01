extends State
# Parent state for all movement-related states for the Player
# Holds all of the base movement logic
# Child states can override this states's functions or change its properties
# This keeps the logic grouped in one location

# These should be fallback defaults
# TODO: Make these null and raise an exception to indicate bad State extension
#       to better separate movement vars.
export var max_speed = 100
export var move_speed = 20
export var gravity = 0.0
export var jump_impulse = 35
export (float, 0.1, 20.0, 0.1) var rotation_speed_factor := 2.0
export (int, 0, 200) var inertia = 1.7

var velocity := Vector3.ZERO
var h_velocity := Vector3.ZERO
var input_direction = Vector3.ZERO
var move_direction = Vector3.ZERO

var camera_pivot = null
var goal_quaternion


func physics_update(delta: float):
	print(inertia)
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
	var input_direction := Vector3(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_up") - Input.get_action_strength("move_down"),
		Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	)
	
	return input_direction


func calculate_movement_direction(input_direction, _delta) -> Vector3:
	var forwards := Vector3.ZERO
	var right := Vector3.ZERO
	var up := Vector3.ZERO
	
	# We calculate a move direction vector relative to the camera,
	# the basis stores the (right, up, -forwards) vectors of our camera.
	forwards = input_direction.z * _actor.camera.global_transform.basis.z
	right = input_direction.x * _actor.camera.global_transform.basis.x
	up = input_direction.y * Vector3.UP
	move_direction = forwards + right + up
	
	if move_direction.length() > 1.0:
		move_direction = move_direction.normalized()
	
	return move_direction 


func calculate_velocity(velocity_current: Vector3, move_direction: Vector3, delta: float):
	h_velocity = h_velocity.linear_interpolate(move_direction * move_speed, inertia * delta)
	var velocity_new = h_velocity
	
	if velocity_new.length() > max_speed:
		velocity_new = velocity_new.normalized() * max_speed
#	velocity_new.y = velocity_current.y + gravity * delta
	
	return velocity_new
