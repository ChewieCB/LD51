extends Node

var PLAYER_CONTROLS_ACTIVE = true
var CAMERA_CONTROLS_ACTIVE = true
var CAMERA_INVERT_X = false
var CAMERA_INVERT_Y = false
var SHOW_STATE_LABELS = false
var SHOW_DEBUG_TRAJECTORIES = false

# Settings
var FULLSCREEN = true setget set_FULLSCREEN


func set_FULLSCREEN(value):
	FULLSCREEN = value
	OS.set_window_fullscreen(FULLSCREEN)
