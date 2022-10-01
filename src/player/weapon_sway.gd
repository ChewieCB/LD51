extends Spatial

var mouse_move
var sway_threshold = 8
var sway_lerp = 0

export var sway_left: Vector3
export var sway_right: Vector3
export var sway_normal: Vector3


func _input(event):
	if event is InputEventMouseMotion:
		mouse_move = -event.relative.x


func _process(delta):
	if mouse_move:
		if mouse_move > sway_threshold:
			rotation = rotation.linear_interpolate(sway_left, sway_lerp * delta)
		elif mouse_move < -sway_threshold:
			rotation = rotation.linear_interpolate(sway_left, sway_lerp * delta)
		else:
			rotation = rotation.linear_interpolate(sway_normal, sway_lerp * delta)
