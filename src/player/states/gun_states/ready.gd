extends State

export var damage = 100
export (Array, AudioStream) var shot_sfx


func physics_update(delta: float):
	if Input.is_action_just_pressed("fire"):
		if _actor.gun_anim_player.is_playing():
			return
		_actor.gun_anim_player.play("fire")
		play_random_shot()
		if _actor.aim_cast.is_colliding():
			var target = _actor.aim_cast.get_collider()
			if target.is_in_group("Enemy"):
				print("Hit " + target.name)
				target.health -= damage

func play_random_shot():
	if shot_sfx:
		var idx = int(rand_range(0, len(shot_sfx)))
		_actor.gun_audio_player.stream = shot_sfx[idx]
		_actor.gun_audio_player.play()
