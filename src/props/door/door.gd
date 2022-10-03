extends Spatial

onready var anim_player = $AnimationPlayer

var can_interact = false

export (bool) var is_open = false setget set_is_open
export (bool) var is_sealed = false


func _ready():
	yield(owner, "ready")
	match is_open:
		true:
			anim_player.play("open")
		false:
			anim_player.play("close")
	PingTimer.connect("ping", self, "toggle_door")


func toggle_door():
	if not is_sealed:
		match is_open:
			true:
				anim_player.play("closing")
				yield(anim_player, "animation_finished")
				is_open = false
			false:
				anim_player.play("opening")
				yield(anim_player, "animation_finished")
				is_open = true


func set_is_open(value):
	is_open = value
