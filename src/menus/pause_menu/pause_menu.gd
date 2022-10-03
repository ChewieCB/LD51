extends Control

onready var audio_player = $MenuAudioPlayer

onready var resume_button = $CenterContainer/VBoxContainer/ResumeContainer/ResumeButton
onready var windowed_button = $CenterContainer/VBoxContainer/OptionsContainer/HBoxContainer/WindowedButton
onready var fullscreen_button = $CenterContainer/VBoxContainer/OptionsContainer/HBoxContainer/FullscreenButton
onready var quit_button = $CenterContainer/VBoxContainer/QuitContainer/QuitButton
onready var buttons = [resume_button, windowed_button, fullscreen_button, quit_button]


func _ready():
	# Set all buttons to have an initial focus mode of FOCUS_ALL
	resume_button.focus_mode = 2
	quit_button.focus_mode = 2
	
	# Windowed/fullscreen set
	if GlobalFlags.FULLSCREEN:
		windowed_button.disabled = false
		fullscreen_button.disabled = true
		# For windowed/fullscreen we disable focus on whichever is active
		windowed_button.focus_mode = 2
		fullscreen_button.focus_mode = 0
	else:
		windowed_button.disabled = true
		fullscreen_button.disabled = false
		# For windowed/fullscreen we disable focus on whichever is active
		windowed_button.focus_mode = 0
		fullscreen_button.focus_mode = 2
	
	Input.connect("joy_connection_changed", self, "controller_ui_focus")
	
	# Connect the focus_enter signal for each button to the sfx player
	for _button in buttons:
		_button.connect("focus_entered", audio_player, "cursor")


func _physics_process(_delta):
	if Input.is_action_just_released("pause"):
		toggle_pause_menu()


func _process(_delta):
	if get_tree().paused:
		if Input.is_action_just_released("ui_down") or \
		Input.is_action_just_released("ui_up"):
			# We only want this to grab focus on the FIRST pressing when 
			# no buttons have focus, so if any buttons currently have focus, exit.
			for _button in buttons:
				if _button.has_focus():
					return
			
			resume_button.grab_focus()


func toggle_pause_menu():
	audio_player.pause_sfx()
	get_tree().paused = !get_tree().paused
	self.visible = !self.visible
	
	if self.visible and get_tree().paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		# If a joypad is connected, grab focus
		if Input.get_connected_joypads():
			audio_player.suppress_click = true
			resume_button.grab_focus()
			audio_player.suppress_click = false
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func controller_ui_focus(device, connected):
	var has_focus = false
	var button_with_focus
	
	# Determine if we already have focus
	for _button in buttons:
		if _button.has_focus():
			has_focus = true
			button_with_focus = _button
			break
	
	if connected and not has_focus:
		resume_button.grab_focus()
	elif not connected and has_focus:
		button_with_focus.release_focus()


func _on_ResumeButton_pressed():
	audio_player.confirm()
	toggle_pause_menu()


func _on_QuitButton_pressed():
	audio_player.back()
	get_tree().quit()
#	get_tree().change_scene("res://src/ui/menus/main_menu/MainMenu.tscn")


func _on_WindowedButton_pressed():
	windowed_button.disabled = true
	fullscreen_button.disabled = false
	audio_player.cursor()
	GlobalFlags.set_FULLSCREEN(false)

	# For windowed/fullscreen we disable focus on whichever is active
	windowed_button.focus_mode = 0
	fullscreen_button.focus_mode = 2
	# Grab focus of the active button so we don't lose focus
	fullscreen_button.grab_focus()


func _on_FullscreenButton_pressed():
	windowed_button.disabled = false
	fullscreen_button.disabled = true
	audio_player.cursor()
	GlobalFlags.set_FULLSCREEN(true)

	# For windowed/fullscreen we disable focus on whichever is active
	windowed_button.focus_mode = 2
	fullscreen_button.focus_mode = 0
	# Grab focus of the active button so we don't lose focus
	windowed_button.grab_focus()

