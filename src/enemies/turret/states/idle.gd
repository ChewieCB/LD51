extends State


func enter(_msg := {}) -> void:
	if not _actor.is_loaded:
		return
	# FIXME - need to separate the light from the rest of the mesh
#	_actor.eye_mesh.set_surface_material(0, _actor.idle_mat)
	_actor.viewcone_mesh.set_surface_material(0, _actor.idle_transparent_mat)
	_actor.anim_state_machine.travel("inactive")


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass


func exit() -> void:
	pass
