extends Control

export (Array, Texture) var npc_portraits
export (int) var current_portrait setget set_current_portait

onready var portrait_rect = $MarginContainer/HBoxContainer/CenterContainer/TextureRect
onready var default_portrait = load("res://assets/ui/npc_dialog/frame.png")
onready var dialog = $MarginContainer/HBoxContainer/CenterContainer2/Label
onready var dialog_manager = $DialogManager

var dialogue_data: Dictionary
var current_dialog_text = "" setget set_current_dialog_text


func _ready():
#	yield(owner, "ready")
	# Clear the initial portrait texture
	set_current_portait(default_portrait)
	set_current_dialog_text("")
	self.visible = true
	
	dialog_manager.connect("start_dialog", self, "start_dialog")
	dialog_manager.connect("dialog_finished", self, "end_dialog")


func start_dialog(portrait: Texture, text: String):
	set_current_portait(portrait)
	set_current_dialog_text(text)


func end_dialog():
	set_current_portait(default_portrait)
	set_current_dialog_text("")


func set_current_portait(value):
	current_portrait = value
	if portrait_rect:
		portrait_rect.texture = current_portrait


func set_current_dialog_text(value):
	current_dialog_text = value
	dialog.text = current_dialog_text
