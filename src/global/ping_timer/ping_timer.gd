extends Timer

signal ping

onready var anim_player = $AnimationPlayer


func _ready():
	anim_player.play("start_timer")


func _process(_delta):
	var current_pos = $BGMPlayer.get_playback_position()
	var current_step = stepify(current_pos, 0.1)
	if current_step == 0:
		return
	var value = fmod(current_step, 10)
	if value == 0:
		$AudioStreamPlayer.play()
		emit_signal("ping")


