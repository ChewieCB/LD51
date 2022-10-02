extends KinematicBody

onready var state_machine = $StateMachine
onready var base = $Mesh/CameraBase
onready var pivot = $Mesh/EyePivot
onready var eye_mesh = $Mesh/EyePivot/CameraEye
onready var viewcone = $Mesh/EyePivot/CameraEye/Viewcone
onready var viewcone_mesh = $Mesh/EyePivot/CameraEye/Viewcone/Cone
onready var ray = $Mesh/EyePivot/CameraEye/RayCast
onready var anim_player = $AnimationPlayer
onready var audio_player = $AudioStreamPlayer3D
onready var tween = $Tween
onready var state_label = $StateLabel

onready var initial_rotation = self.rotation_degrees

export (Material) var idle_mat
export (Material) var idle_transparent_mat
export (Material) var tracking_mat
export (Material) var tracking_transparent_mat
export (Material) var alert_mat
export (Material) var alert_transparent_mat

export (Array, AudioStream) var death_sfx
export (AudioStream) var found_sfx
export (AudioStream) var lost_sfx

export var max_health = 100
export var health = 100 setget set_health

export (Array, NodePath) var linked_turrets = []

var has_seen_player = false setget set_has_seen_player
var can_interact = false
var target: PlayerController = null

# Tracking Speed
export var elevation_speed_deg: float = 45
export var rotation_speed_deg: float = 90
# Rotation Constraints
export var min_elevation: float = -30
export var max_elevation: float = 30
export var min_rotation: float = -60
export var max_rotation: float = 60
# movement
onready var elevation_speed: float = deg2rad(elevation_speed_deg)
onready var rotation_speed: float = deg2rad(rotation_speed_deg)
# target calculation
var ttc: float
var current_target: Vector3
var current_aim: Vector3


func _ready():
	PingTimer.connect("timeout", self, "ping_effect")
	state_machine.connect("transitioned", self, "update_state_label")
#	$StateMachine/Destroyed.connect("destroyed", self, "destroy_camera")
#	yield(get_tree().create_timer(rand_range(0, 0.5)), "timeout")


#func _process(delta):
#	if has_seen_player and target:
#		# update target location
#		_update_target_location()
#		# move
#		_rotate(delta)
#		_elevate(delta)


func _update_target_location() -> void:
	current_target = target.global_transform.origin


func _rotate(delta: float) -> void:
	# get displacment
	var y_target = _get_local_y()
	# calculate step size and direction
	var final_y = sign(y_target) * min(rotation_speed * delta, abs(y_target))
	# rotate body
	pivot.rotate_y(final_y)
	# clamp
	pivot.rotation_degrees.y = clamp(
		pivot.rotation_degrees.y,
		min_rotation, max_rotation
	)


func _elevate(delta: float) -> void:
	# get displacment
	var x_target = _get_global_x()
	var x_diff = x_target - pivot.global_transform.basis.get_euler().x
	var final_x = sign(x_diff) * min(elevation_speed * delta, abs(x_diff))
	# elevate head
	pivot.rotate_x(final_x)
	# clamp
	pivot.rotation_degrees.x = clamp(
		pivot.rotation_degrees.x,
		min_elevation, max_elevation
	)


func _rotate_pivot(delta):
	var y_target = _get_local_y()
	var final_y = sign(y_target) * min(rotation_speed * delta, abs(y_target))
	pivot.rotate_y(final_y)


func _rotate_guns(delta):
	var x_target = _get_global_x()
	var x_diff = x_target - eye_mesh.transform.basis.get_euler().x
	var final_x = sign(x_diff) * min(rotation_speed * delta, abs(x_diff))
	eye_mesh.rotate_x(final_x)
	eye_mesh.rotation_degrees.x = clamp(
		eye_mesh.rotation_degrees.x,
		-90, 90
	)


func _get_local_y() -> float:
	var local_target = pivot.to_local(current_target)
	var y_angle = Vector3.FORWARD.angle_to(local_target * Vector3(1, 0, 1))
	return y_angle * -sign(local_target.x)


func _get_global_x() -> float:
	var local_target = current_target - pivot.global_transform.origin
	return (local_target * Vector3(1, 0, 1)).angle_to(local_target) * sign(local_target.y)


func _input(event):
	if not can_interact:
		return
	if event.is_action_pressed("interact"):
		print("interacted with " + self.name)
		state_machine.transition_to("Destroyed")


func ping_effect():
	match state_machine.state.name:
		"Idle":
			# Flash red to indicate the ping has hit
			eye_mesh.set_surface_material(1, alert_mat)
			viewcone_mesh.set_surface_material(0, alert_transparent_mat)
			yield(get_tree().create_timer(1), "timeout")
			eye_mesh.set_surface_material(1, idle_mat)
			viewcone_mesh.set_surface_material(0, idle_transparent_mat)
		"Tracking":
			state_machine.transition_to("Alert")


func destroy_camera():
	self.queue_free()


func play_random_death_sfx():
	if death_sfx:
		var idx = int(rand_range(0, len(death_sfx)))
		audio_player.stream = death_sfx[idx]
		audio_player.play()


func update_state_label(state_name) -> void:
	state_label.text = state_name


func _on_Viewcone_body_entered(body):
	if state_machine.state.name == "Destroyed":
		return
	if body is PlayerController:
#		pivot.look_at(body.global_transform.origin, self.global_transform.basis.y)
#		pivot.rotate_object_local(Vector3(0,1,0), 3.14)
#		var local = ray.to_local(target.global_transform.origin)
#		ray.cast_to = local
		target = body
		set_has_seen_player(true)
		audio_player.stream = found_sfx
		audio_player.play()


func _on_Viewcone_body_exited(body):
	if state_machine.state.name == "Destroyed":
		return
	if body is PlayerController:
		target = null
		set_has_seen_player(false)
		audio_player.stream = lost_sfx
		audio_player.play()


func set_has_seen_player(value):
	has_seen_player = value
	match has_seen_player:
		true:
			state_machine.transition_to("Tracking")
		false:
			state_machine.transition_to("Idle")


func set_health(value):
	health = clamp(value, 0, max_health)
	if health == 0:
		state_machine.transition_to("Destroyed")


func _on_InteractionArea_body_entered(body):
	if body is PlayerController:
		can_interact = true
		print("can interact with " + self.name)


func _on_InteractionArea_body_exited(body):
	if body is PlayerController:
		can_interact = false
