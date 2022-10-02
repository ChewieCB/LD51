extends State


func enter(_msg := {}) -> void:
	# FIXME - need to separate the light from the rest of the mesh
#	_actor.eye_mesh.set_surface_material(0, _actor.alert_mat)
	_actor.viewcone_mesh.set_surface_material(0, _actor.alert_transparent_mat)
	yield(get_tree().create_timer(rand_range(0, 0.8)), "timeout")
	_actor.anim_state_machine.travel("burst_fire")
	# Do action here
	#

func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass


func exit() -> void:
	pass
