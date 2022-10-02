extends State


func enter(_msg := {}) -> void:
	_actor.eye_mesh.set_surface_material(1, _actor.tracking_mat)
	_actor.viewcone_mesh.set_surface_material(0, _actor.tracking_transparent_mat)
	_actor.anim_player.play("find")


func update(delta: float) -> void:
	# update target location
	_actor._update_target_location()
	# move
	_actor._rotate(delta)
	_actor._elevate(delta)


func physics_update(_delta: float) -> void:
	pass


func exit() -> void:
	_actor.anim_player.play("lose")
