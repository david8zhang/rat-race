class_name Game
extends Node2D

@export var rat_scene: PackedScene
var lanes = []

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
		lanes[i].add_rat_to_lane(rat)
		add_child(rat)
