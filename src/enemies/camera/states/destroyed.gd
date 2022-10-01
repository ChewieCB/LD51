extends State

signal destroyed


func enter(_msg := {}) -> void:
	_actor.anim_player.play("death")
	_actor.audio_player.play()
	yield(_actor.anim_player, "animation_finished")
	yield(_actor.audio_player, "finished")
	emit_signal("destroyed")


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass


func exit() -> void:
	pass
