extends Spatial

onready var box = $CSGBox
onready var hue = 0

func _physics_process(delta):
	box.rotation += Vector3(0, delta, 0)
	hue += 0.001
	if hue > 1:
		hue = 0
	var new_colour = Color.from_hsv(hue, 1, 1, 1)
	box.material.albedo_color = new_colour

