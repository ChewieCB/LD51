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
	if Input.is_action_just_pressed("fire"):
		if _actor.aim_cast.is_colliding():
			var target = _actor.aim_cast.get_collider()
