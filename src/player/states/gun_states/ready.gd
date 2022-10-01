extends State

export var damage = 100


func physics_update(delta: float):
	if Input.is_action_just_pressed("fire"):
		if _actor.gun_anim_player.is_playing():
			return
		_actor.gun_anim_player.play("fire")
		if _actor.aim_cast.is_colliding():
			var target = _actor.aim_cast.get_collider()
			if target.is_in_group("Enemy"):
				print("Hit " + target.name)
				target.health -= damage
