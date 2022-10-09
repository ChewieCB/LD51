extends State


func enter(_msg := {}) -> void:
	if not _actor.is_loaded:
		return
	# FIXME - need to separate the light from the rest of the mesh
#	_actor.eye_mesh.set_surface_material(0, _actor.tracking_mat)
	_actor.viewcone_mesh.set_surface_material(0, _actor.tracking_transparent_mat)
	_actor.anim_state_machine.travel("default")

func update(delta: float) -> void:
	if not _actor.is_loaded:
		return
	if _actor.target:
		_actor._rotate_base(delta, _actor.slower_rotation_speed)
		_actor._rotate_guns(delta, _actor.slower_rotation_speed)


func physics_update(_delta: float) -> void:
	pass


func exit() -> void:
	pass
