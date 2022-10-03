extends KinematicBody
class_name PlayerController

onready var mesh = $MeshInstance
onready var collider = $BodyCollider
onready var tween = $Tween
onready var jet_audio_player = $JetPlayer
onready var impact_audio_player = $ImpactPlayer
onready var injury_audio_player = $InjuryPlayer
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
onready var game_over = $UI/GameOver

export (Array, AudioStream) var movement_sfx
export (Array, AudioStream) var impact_sfx
export (Array, AudioStream) var hurt_sfx
export (AudioStream) var death_sfx

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


func play_random_sfx(player, sfx_array: Array):
	# If we already have a stream set, remove it
	var existing_sfx = []
	for element in sfx_array:
		existing_sfx.append(element)
	
	if player.stream:
		existing_sfx.erase(player.stream)
	
	var rand_idx = int(rand_range(0, existing_sfx.size()))
	player.stream = existing_sfx[rand_idx]
	player.play()


func game_over():
	game_over.anim_player.play("fade_in")
	GlobalFlags.PLAYER_CONTROLS_ACTIVE = false
	GlobalFlags.CAMERA_CONTROLS_ACTIVE = false
	yield(game_over.anim_player, "animation_finished")
	yield(get_tree().create_timer(1.0), "timeout")
	game_over.anim_player.play("fade_out")
	yield(game_over.anim_player, "animation_finished")
	GlobalFlags.PLAYER_CONTROLS_ACTIVE = true
	GlobalFlags.CAMERA_CONTROLS_ACTIVE = true
	get_tree().reload_current_scene()


func set_inertia(value):
	movement_state.inertia = value


func set_speed(value):
	movement_state.move_speed = value


func set_health(value):
	if value < health:
		hit_screen.hit()
		play_random_sfx(impact_audio_player, impact_sfx)
		play_random_sfx(injury_audio_player, hurt_sfx)
		
	health = clamp(value, 0, max_health)
	
	hud.health_bar.value = health
	
	if health == 0:
		play_random_sfx(injury_audio_player, [death_sfx])
		game_over()
