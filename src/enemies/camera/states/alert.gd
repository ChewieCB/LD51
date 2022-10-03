extends State


func enter(_msg := {}) -> void:
	_actor.eye_mesh.set_surface_material(1, _actor.alert_mat)
	_actor.viewcone_mesh.set_surface_material(0, _actor.alert_transparent_mat)
#	_actor.anim_player.play("find")
	
	if _actor.has_seen_player:
		for turret_path in _actor.linked_turrets:
			var turret = _actor.get_node(turret_path)
			turret.target = _actor.target
			if not turret.is_active:
				turret.set_is_active(true)
			turret.state_machine.transition_to("Shooting")
			turret.state_machine.transition_to("Alert")


func update(delta: float) -> void:
	# update target location
	_actor._update_target_location()
	# move
	_actor._rotate(delta)
	_actor._elevate(delta)


func physics_update(_delta: float) -> void:
	pass


func exit() -> void:
	pass
#	for turret_path in _actor.linked_turrets:
#		var turret = _actor.get_node(turret_path)
#		if turret.is_active:
#			turret.set_is_active(false)
#	_actor.anim_player.play("lose")
