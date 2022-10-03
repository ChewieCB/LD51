extends Spatial

onready var state_machine = $StateMachine
onready var pivot = $TurretMesh/TurretBase/TurretHinge/TurretGuns
onready var base = $TurretMesh/TurretBase
onready var eye_mesh = $TurretMesh/TurretBase/TurretHinge/TurretGuns
onready var viewcone = $TurretMesh/TurretBase/TurretHinge/TurretGuns/Viewcone
onready var viewcone_mesh = $TurretMesh/TurretBase/TurretHinge/TurretGuns/Viewcone/Cone
onready var rays = $TurretMesh/TurretBase/TurretHinge/TurretGuns/Raycasts.get_children()
onready var anim_player = $AnimationPlayer
onready var anim_tree = $AnimationTree
onready var anim_state_machine = anim_tree["parameters/playback"]
onready var audio_player = $AudioStreamPlayer3D
onready var tween = $Tween

onready var aim_casts = $TurretMesh/TurretBase/TurretHinge/TurretGuns/Raycasts

onready var state_label = $StateLabel

onready var initial_rotation = self.rotation_degrees

export (Material) var idle_mat
export (Material) var idle_transparent_mat
export (Material) var tracking_mat
export (Material) var tracking_transparent_mat
export (Material) var alert_mat
export (Material) var alert_transparent_mat

export var max_health = 200
export var health = 200 setget set_health

export var damage = 10

export var rotation_speed = deg2rad(65.0) # Since all values are in radians, this needs to be in radians too
export var slower_rotation_speed = deg2rad(45.0)
export var faster_rotation_speed = deg2rad(80.0)

export (bool) var is_active = false setget set_is_active
var can_ping  = false setget set_can_ping
var has_seen_player = false setget set_has_seen_player
var can_interact = false
var target: PlayerController = null

var debug_trajectory_meshes = []


func _ready():
	PingTimer.connect("ping", self, "ping_effect")
	state_machine.connect("transitioned", self, "update_state_label")
	$StateMachine/Destroyed.connect("destroyed", self, "destroy")
	yield(owner, "ready")


#func _process(delta):
#	if has_seen_player and target:
#		# Separate rotation axis to animate the base and the gun components separately
#		_rotate_base(delta)
#		_rotate_guns(delta)


func _rotate_base(delta, speed):
	var y_target = _get_local_y()
	var final_y = sign(y_target) * min(speed * delta, abs(y_target))
	base.rotate_y(final_y)


func _rotate_guns(delta, speed):
	var x_target = _get_global_x()
	var x_diff = x_target - eye_mesh.transform.basis.get_euler().x
	var final_x = sign(x_diff) * min(speed * delta, abs(x_diff))
	eye_mesh.rotate_x(final_x)
	eye_mesh.rotation_degrees.x = clamp(
		eye_mesh.rotation_degrees.x,
		-90, 90
	)

func _get_global_x():
	var local_target = target.global_transform.origin - eye_mesh.global_transform.origin
#	local_target.y -= 0.5
	return (local_target * Vector3(1, 0, 1)).angle_to(local_target) * sign(local_target.y)


func _get_local_y():
	var local_target = base.to_local(target.global_transform.origin)
	var y_angle = Vector3.FORWARD.angle_to(local_target + Vector3(1, 0, 1))
	return y_angle * -sign(local_target.x)


func activate():
	if has_seen_player:
		state_machine.transition_to("Alert")
	else:
		state_machine.transition_to("Idle")


func deactivate():
	if not state_machine.state.name == "Destroyed":
		state_machine.transition_to("Inactive")


func _input(event):
	if not can_interact:
		return
	if event.is_action_pressed("interact"):
		print("interacted with " + self.name)
		state_machine.transition_to("Destroyed")


func ping_effect():
	if is_active and can_ping:
		match state_machine.state.name:
			"Idle":
				# Flash red to indicate the ping has hit
				state_machine.transition_to("Alert")
				yield(get_tree().create_timer(0.2), "timeout")
				state_machine.transition_to("Idle")
			"Tracking":
				state_machine.transition_to("Alert")
			"Alert":
				state_machine.transition_to("Shooting")
				# For now yield for the animation time and flip back,
				# in future we want to execute some code in the state
				# before returning
				yield(get_tree().create_timer(1.1), "timeout")
				state_machine.transition_to("Alert")


func generate_debug_trajectory(trajectory_points, size):
	if not GlobalFlags.SHOW_DEBUG_TRAJECTORIES:
		return
	
	clear_debug_trajectory()
	# Get scene root
	var scene_root = get_tree().root.get_children()[0]
	for _point in trajectory_points:
		# Create sphere with low detail of size.
		var sphere = SphereMesh.new()
		sphere.radial_segments = 8
		sphere.rings = 8
		sphere.radius = size
		sphere.height = size * 2
		# Bright red material (unshaded).
		var material = SpatialMaterial.new()
		material.albedo_color = Color(1, 0, 0)
		material.flags_unshaded = true
		sphere.surface_set_material(0, material)
		
		# Add to meshinstance in the right place.
		var node = MeshInstance.new()
		node.mesh = sphere
		if node.is_inside_tree():
			node.global_transform.origin = _point
		scene_root.add_child(node)
		debug_trajectory_meshes.append(node)


func clear_debug_trajectory():
	for mesh in debug_trajectory_meshes:
		mesh.queue_free()
	debug_trajectory_meshes = []


func destroy():
	yield(get_tree().create_timer(1.0), "timeout")
	self.queue_free()


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


func _on_Viewcone_body_exited(body):
	if state_machine.state.name == "Destroyed":
		return
	if body is PlayerController:
		target = null
		set_has_seen_player(false)


func set_has_seen_player(value):
	has_seen_player = value
	match has_seen_player:
		true:
			match state_machine.state.name:
				"Idle", "Tracking":
					state_machine.transition_to("Alert")

		false:
			match state_machine.state.name:
				"Tracking":
					state_machine.transition_to("Idle")
				"Alert":
					state_machine.transition_to("Tracking")
				"Shooting":
					state_machine.transition_to("Alert")


func set_health(value):
	health = clamp(value, 0, max_health)
	if health == 0:
		state_machine.transition_to("Destroyed")


func set_is_active(value):
	is_active = value
	if not anim_player:
		return
	match is_active:
		true:
			activate()
		false:
			deactivate()


func set_can_ping(value):
	can_ping = value


func _on_InteractionArea_body_entered(body):
	if body is PlayerController:
		can_interact = true
		print("can interact with " + self.name)


func _on_InteractionArea_body_exited(body):
	if body is PlayerController:
		can_interact = false
