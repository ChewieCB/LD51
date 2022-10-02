extends State


func enter(_msg := {}) -> void:
	_actor.eye_mesh.set_surface_material(0, _actor.idle_mat)
	_actor.viewcone_mesh.set_surface_material(0, _actor.idle_transparent_mat)


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass


func exit() -> void:
	pass
