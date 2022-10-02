extends State


func enter(_msg := {}) -> void:
	# FIXME - need to separate the light from the rest of the mesh
#	_actor.eye_mesh.set_surface_material(0, _actor.alert_mat)
	_actor.viewcone_mesh.set_surface_material(0, _actor.alert_transparent_mat)

func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	# Separate rotation axis to animate 
	# the base and the gun components separately
	# Base rotates around the Y-axis
	_actor.base.look_at(
		_actor.target.global_transform.origin, 
		_actor.global_transform.basis.y
	)
	_actor.base.rotation.x = 0
	_actor.base.rotation.z = 0
	# Guns rotates around the X-axis
	_actor.eye_mesh.look_at(
		_actor.target.global_transform.origin, 
		_actor.global_transform.basis.y
	)
	_actor.eye_mesh.rotation.y = 0
	_actor.eye_mesh.rotation.z = 0


func exit() -> void:
	pass
