extends State

signal destroyed


func enter(_msg := {}) -> void:
	if not _actor.is_loaded:
		return
	_actor.anim_state_machine.travel("destroy")
#	_actor.anim_player.play("death")
#	yield(_actor.anim_player, "animation_finished")
	emit_signal("destroyed")


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass


func exit() -> void:
	pass
