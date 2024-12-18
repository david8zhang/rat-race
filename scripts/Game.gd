class_name Game
extends Node2D

@export var rat_scene: PackedScene
@onready var cat = $Cat as Cat

var lanes = []
var player_controlled_rat: Rat

const NUM_RATS = 4
const NUM_LANES = 6

func _ready():
	var lane_y_pos = 300
	for i in range(0, NUM_LANES):
		var lane = Lane.create_new(lane_y_pos)
		lanes.append(lane)
		add_child(lane)
		lane_y_pos += 50

	for i in range(0, NUM_RATS):
		var rat = rat_scene.instantiate() as Rat
		if i == 0:
			rat.is_player_controlled = true
			player_controlled_rat = rat
		lanes[i].add_rat_to_lane(rat)
		add_child(rat)

	cat.on_hide.connect(on_cat_hide)
	cat.on_peek.connect(on_cat_peek)
	cat.on_watch.connect(on_cat_watch)

func on_cat_peek():
	print("Game handle cat peek!")

func on_cat_watch():
	print("Game handle cat watch!")

func on_cat_hide():
	print("Game handle cat hide")
