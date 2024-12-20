class_name GameOver
extends Node2D

@onready var game_over_label = $CanvasLayer/Label as Label

func _ready():
	var winner_rat_name = PlayerVariables.winner_rat_name
	game_over_label.text = winner_rat_name + " is the winner!"
