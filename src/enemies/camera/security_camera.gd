extends KinematicBody

onready var state_machine = $StateMachine
onready var initial_position = self.global_transform.origin
onready var ray_node = $Rays

export var angle_cone_of_vision := deg2rad(30.0)
export var max_view_distance :=  800.0
export var angle_between_rays := deg2rad(5.0)

var has_seen_player = false setget set_seen_player
var target: PlayerController = null

#
#func _ready():
#	generate_raycasts()


func generate_raycasts() -> void:
	var ray_count := angle_cone_of_vision / angle_between_rays
	
	for index in ray_count:
		var ray := RayCast.new()
		var angle = angle_between_rays * (index - ray_count / 2.0)
		ray.cast_to = Vector3.UP.rotated(Vector3.UP, angle) * max_view_distance
		ray_node.add_child(ray)
		ray.enabled = true


func _physics_process(_delta):
	for ray in ray_node.get_children():

		if ray.is_colliding() and ray.get_collider() is PlayerController:
			target = ray.get_collider()
			break
	
	has_seen_player = target != null
	
	if has_seen_player:
		look_at(target.global_transform.origin, self.global_transform.basis.y)
		self.rotate_object_local(Vector3(0,1,0), 3.14)
	
	
#	if has_seen_player:
#		if raycast.is_colliding():
#			if raycast.get_collider() is PlayerController:
#				target = raycast.get_collider()
#			look_at(target.global_transform.origin, self.global_transform.basis.y)
#			self.rotate_object_local(Vector3(0,1,0), 3.14)
#		else:
#			has_seen_player = false


func _on_Viewcone_body_entered(body):
	if body is PlayerController:
		has_seen_player = true
		target = body


func _on_Viewcone_body_exited(body):
	if body is PlayerController:
		has_seen_player = false
		target = null


func set_seen_player(value):
	has_seen_player = value
	if not has_seen_player:
		look_at(initial_position, self.global_transform.basis.y)
		self.rotate_object_local(Vector3(0,1,0), 3.14)

