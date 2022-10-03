extends State


func enter(_msg := {}) -> void:
	# FIXME - need to separate the light from the rest of the mesh
#	_actor.eye_mesh.set_surface_material(0, _actor.alert_mat)
	_actor.viewcone_mesh.set_surface_material(0, _actor.alert_transparent_mat)
	yield(get_tree().create_timer(rand_range(0, 0.8)), "timeout")
	_actor.anim_state_machine.travel("burst_fire")

func update(delta: float) -> void:
	if _actor.target:
		_actor._rotate_base(delta, _actor.faster_rotation_speed)
		_actor._rotate_guns(delta, _actor.faster_rotation_speed)


func check_hit():
	# Check all three raycasts, if one of them hits the player then deal damage
	for ray in _actor.aim_casts.get_children():
		if ray.is_colliding():
			var target = ray.get_collider()
			if target is PlayerController:
				target.health -= _actor.damage
				break


func physics_update(_delta: float) -> void:
	pass


func exit() -> void:
	pass
