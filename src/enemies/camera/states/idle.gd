extends State


func enter(_msg := {}) -> void:
	var new_colour = _actor.idle_colour
	var new_colour_trans = new_colour; new_colour_trans.a = 0.5
	_actor.eye_mesh.get_active_material(0).albedo_color = new_colour
	_actor.viewcone_mesh.get_active_material(0).albedo_color = new_colour_trans

func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass


func exit() -> void:
	pass
