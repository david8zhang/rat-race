class_name Rat
extends Node2D

var is_player_controlled = false
var num_key_presses = 0

func _input(event):
	if is_player_controlled:
		var just_pressed = event.is_pressed() and not event.is_echo()
		if Input.is_key_pressed(KEY_SPACE) and just_pressed:
			global_position.x += 2
