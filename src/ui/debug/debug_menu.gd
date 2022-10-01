extends Control

onready var floaty_slider = $MarginContainer/Panel/MarginContainer/VBoxContainer/InertiaSlider/MarginContainer/HBoxContainer/HSlider
onready var floaty_count = $MarginContainer/Panel/MarginContainer/VBoxContainer/InertiaSlider/MarginContainer/HBoxContainer/Count
onready var speed_slider = $MarginContainer/Panel/MarginContainer2/VBoxContainer/MovementSpeedSlider/MarginContainer/HBoxContainer/HSlider
onready var speed_count = $MarginContainer/Panel/MarginContainer2/VBoxContainer/MovementSpeedSlider/MarginContainer/HBoxContainer/Count


func _on_InertiaSlider_value_changed(value):
	floaty_count.text = str(value)


func _on_SpeedSlider_value_changed(value):
	speed_count.text = str(value)
