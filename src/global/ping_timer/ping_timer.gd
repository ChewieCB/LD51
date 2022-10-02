extends Timer



func _on_Timer_timeout():
	$AudioStreamPlayer.play()
