extends State


func enter(_msg := {}) -> void:
	_actor.eye_mesh.set_surface_material(1, _actor.idle_mat)
	_actor.viewcone_mesh.set_surface_material(0, _actor.idle_transparent_mat)
	# Reset camera position before resuming rotation
	if _actor.pivot.rotation_degrees != _actor.initial_rotation and _actor.tween.is_inside_tree():
		_actor.anim_player.stop()
		_actor.tween.interpolate_property(
			_actor.pivot, "rotation_degrees",
			_actor.pivot.rotation_degrees, _actor.initial_rotation,
			2.0,
			Tween.TRANS_QUAD, Tween.EASE_IN_OUT
		)
		_actor.tween.start()
		yield(_actor.tween, "tween_completed")
	
	_actor.anim_player.play("rotate")


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass


func exit() -> void:
	_actor.anim_player.stop(true)
