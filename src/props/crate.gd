extends RigidBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	self.angular_velocity = Vector3(
		rand_range(-0.3, 0.3),
		rand_range(-0.3, 0.3),
		rand_range(-0.3, 0.3)
	)



