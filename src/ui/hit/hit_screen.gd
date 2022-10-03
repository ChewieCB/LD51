extends Control


onready var anim_player = $AnimationPlayer


func hit():
	anim_player.play("hit")

