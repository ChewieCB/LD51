extends KinematicBody

onready var state_machine = $StateMachine
onready var pivot = $Pivot
onready var eye_mesh = $Pivot/EyeMesh
onready var viewcone = $Pivot/Viewcone
onready var viewcone_mesh = $Pivot/Viewcone/Cone
onready var ray = $Pivot/RayCast
onready var anim_player = $AnimationPlayer
onready var audio_player = $AudioStreamPlayer3D
onready var tween = $Tween

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

var debug_trajectory_meshes = []


func _ready():
	PingTimer.connect("timeout", self, "ping_effect")
	$StateMachine/Destroyed.connect("destroyed", self, "destroy_camera")
#	yield(get_tree().create_timer(rand_range(0, 0.5)), "timeout")
	anim_player.play("rotate")
	anim_player.seek(rand_range(0, 5))
	


func _physics_process(_delta):
	if has_seen_player == true:
		pivot.look_at(target.global_transform.origin, self.global_transform.basis.y)
#		pivot.rotate_object_local(Vector3(0,1,0), 3.14)


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
			eye_mesh.set_surface_material(0, alert_mat)
			viewcone_mesh.set_surface_material(0, alert_transparent_mat)
			yield(get_tree().create_timer(1), "timeout")
			eye_mesh.set_surface_material(0, idle_mat)
			viewcone_mesh.set_surface_material(0, idle_transparent_mat)
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


func destroy_camera():
	self.queue_free()


func play_random_death_sfx():
	if death_sfx:
		var idx = int(rand_range(0, len(death_sfx)))
		audio_player.stream = death_sfx[idx]
		audio_player.play()


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
			anim_player.stop()
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
			anim_player.play("rotate")


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
