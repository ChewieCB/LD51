extends State


func enter(_msg := {}) -> void:
	# FIXME - need to separate the light from the rest of the mesh
#	_actor.eye_mesh.set_surface_material(0, _actor.tracking_mat)
	_actor.viewcone_mesh.set_surface_material(0, _actor.tracking_transparent_mat)

func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass


func exit() -> void:
	pass
