extends Control

onready var floaty_slider = $MarginContainer/Panel/MarginContainer/VBoxContainer/InertiaSlider/MarginContainer/HBoxContainer/HSlider
onready var floaty_count = $MarginContainer/Panel/MarginContainer/VBoxContainer/InertiaSlider/MarginContainer/HBoxContainer/Count


func _on_HSlider_value_changed(value):
	floaty_count.text = str(value)
