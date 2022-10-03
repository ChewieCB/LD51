extends KinematicBody
class_name PlayerController

onready var mesh = $MeshInstance
onready var collider = $BodyCollider
onready var tween = $Tween
onready var audio_player = $AudioStreamPlayer3D
onready var gun_audio_player = $Camera/Hand/GunAudioPlayer

onready var hue = 0

# Array of all things that should rotate
onready var rotateable = [
	collider,
	$MeshInstance
]

onready var camera = $Camera
onready var gun_camera = $CanvasLayer/ViewportContainer/Viewport/GunCamera
onready var gun_anim_player = $Camera/Hand/GunAnimationPlayer
onready var aim_cast = $Camera/Hand/AimCast

onready var state_machine = $StateMachine
onready var movement_state = $StateMachine/Movement

onready var debug_menu = $UI/DebugMenu
onready var hit_screen = $UI/HitScreen
onready var hud = $UI/HUD

export (Array, AudioStream) var movement_sfx

const SNAP_DIRECTION = Vector3.DOWN
const SNAP_LENGTH = 32

export var max_health = 100
var health = max_health setget set_health


func _ready():
	debug_menu.floaty_slider.connect("value_changed", self, "set_inertia")
	debug_menu.floaty_slider.value = movement_state.inertia
	debug_menu.speed_slider.connect("value_changed", self, "set_speed")
	debug_menu.speed_slider.value = movement_state.move_speed
	
	var main_env = camera.get_environment()
	gun_camera.set_environment(main_env)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT && event.pressed:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta) -> void:
	gun_camera.global_transform = camera.global_transform


func play_random_move_sfx():
	# If we already have a stream set, remove it
	var existing_sfx = []
	for element in movement_sfx:
		existing_sfx.append(element)
	
	if audio_player.stream:
		existing_sfx.erase(audio_player.stream)
	
	var rand_idx = int(rand_range(0, existing_sfx.size()))
	audio_player.stream = existing_sfx[rand_idx]
	audio_player.play()
		


func set_inertia(value):
	movement_state.inertia = value


func set_speed(value):
	movement_state.move_speed = value


func set_health(value):
	if value < health:
		hit_screen.hit()
		
	health = clamp(value, 0, max_health)
	
	hud.health_bar.value = health
	
	if health == 0:
		print("You died!")
		# TODO - add game over/proper restart
		get_tree().reload_current_scene()
