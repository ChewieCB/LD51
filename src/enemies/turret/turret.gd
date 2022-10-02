extends KinematicBody

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

onready var initial_rotation = self.rotation_degrees

export (Material) var idle_mat
export (Material) var idle_transparent_mat
export (Material) var tracking_mat
export (Material) var tracking_transparent_mat
export (Material) var alert_mat
export (Material) var alert_transparent_mat

export var max_health = 200
export var health = 200 setget set_health

var is_active = false setget set_is_active
var has_seen_player = false setget set_has_seen_player
var can_interact = false
var target: PlayerController = null

var debug_trajectory_meshes = []


func _ready():
	PingTimer.connect("timeout", self, "ping_effect")
	$StateMachine/Destroyed.connect("destroyed", self, "destroy")
#	yield(get_tree().create_timer(rand_range(0, 0.5)), "timeout")
#	anim_player.seek(rand_range(0, 5))


func activate():
	anim_state_machine.travel("default")
	pivot.look_at(
		target.global_transform.origin, 
		global_transform.basis.y
	)
#	tween.interpolate_property(
#		pivot, "rotation_degrees",
#		pivot.rotation_degrees, Vector3.ZERO,
#		2.0,
#		Tween.TRANS_QUAD, Tween.EASE_IN_OUT
#	)
#	tween.start()
#	yield(tween, "tween_completed")


func deactivate():
	anim_state_machine.travel("inactive")
#	yield(anim_player, "animation_finished")


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
			state_machine.transition_to("Alert")
			yield(get_tree().create_timer(0.2), "timeout")
			state_machine.transition_to("Idle")
		"Tracking":
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
	pass
#	self.queue_free()


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
			state_machine.transition_to("Tracking")
#			anim_player.stop()
#			if ray.is_colliding():
#				if ray.get_collider() is PlayerController:
#					target = ray.get_collider()
#				else:
#					has_seen_player = false
		false:
			if not tween.is_inside_tree():
				return
			state_machine.transition_to("Idle")
			tween.interpolate_property(
				pivot, "rotation_degrees",
				pivot.rotation_degrees, Vector3.ZERO,
				2.0,
				Tween.TRANS_QUAD, Tween.EASE_IN_OUT
			)
			tween.start()
			yield(tween, "tween_completed")
			anim_state_machine.travel("rotate")


func set_health(value):
	health = clamp(value, 0, max_health)
	if health == 0:
		state_machine.transition_to("Destroyed")


func set_is_active(value):
	is_active = value
	match is_active:
		true:
			activate()
		false:
			deactivate()


func _on_InteractionArea_body_entered(body):
	if body is PlayerController:
		can_interact = true
		print("can interact with " + self.name)


func _on_InteractionArea_body_exited(body):
	if body is PlayerController:
		can_interact = false
