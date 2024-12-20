class_name Lane
extends Node2D

const my_scene: PackedScene = preload("res://prefabs/Lane.tscn")
@onready var sprite = $Sprite2D as Sprite2D

static var INITIAL_START_X = 75
var start_y = 0
var rats_in_lane = []

static func create_new(initial_y: int) -> Lane:
	var lane: Lane = my_scene.instantiate() as Lane
	lane.start_y = initial_y
	return lane

func _ready():
	global_position = Vector2(Lane.INITIAL_START_X, start_y)

func add_rat_to_lane(rat: Rat):
	rats_in_lane.append(rat)
	rat.global_position = Vector2(Lane.INITIAL_START_X, start_y)
