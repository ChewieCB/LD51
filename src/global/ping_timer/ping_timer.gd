extends Timer

signal ping

onready var anim_player = $AnimationPlayer


func _ready():
	anim_player.play("start_timer")


func _process(_delta):
	var current_pos = $BGMPlayer.get_playback_position()
	if fmod(stepify(current_pos, 0.1), 10) == 0:
		$AudioStreamPlayer.play()
		emit_signal("ping")


