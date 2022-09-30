extends KinematicBody
class_name PlayerController

onready var collider = $CollisionShape
onready var tween = $Tween
onready var audio_player = $AudioStreamPlayer3D

# Array of all things that should rotate
onready var rotateable = [
	collider,
	$MeshInstance
]

onready var camera_pivot = get_node("../CameraPivot")
onready var camera = camera_pivot.camera

onready var state_machine = $StateMachine
onready var movement_state = $StateMachine/Movement

const SNAP_DIRECTION = Vector3.DOWN
const SNAP_LENGTH = 32
