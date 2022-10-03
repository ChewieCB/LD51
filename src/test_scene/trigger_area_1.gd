extends Area

export (Array, NodePath) var linked_turrets
 

func _on_TriggerArea1_body_entered(body):
	if not body is PlayerController:
		return
	for turret_path in linked_turrets:
		var turret = get_node(turret_path)
		if turret:
			turret.target = body
			if not turret.is_active:
				turret.set_is_active(true)
			turret.state_machine.transition_to("Shooting")
			turret.state_machine.transition_to("Alert")
	


func _on_TriggerArea1_body_exited(body):
	if not body is PlayerController:
		return
	for turret_path in linked_turrets:
		var turret = get_node(turret_path)
		if turret:
			if turret.is_active:
				turret.set_is_active(false)
