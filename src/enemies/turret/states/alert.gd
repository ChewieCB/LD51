extends State


func enter(_msg := {}) -> void:
	# FIXME - need to separate the light from the rest of the mesh
#	_actor.eye_mesh.set_surface_material(0, _actor.alert_mat)
	_actor.viewcone_mesh.set_surface_material(0, _actor.alert_transparent_mat)

func update(delta: float) -> void:
	if _actor.target:
		_actor._rotate_base(delta)
		_actor._rotate_guns(delta)


func physics_update(_delta: float) -> void:
	pass


func exit() -> void:
	pass
