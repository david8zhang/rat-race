class_name Game
extends Node2D

@export var rat_scene: PackedScene
@onready var cat = $Cat as Cat

var lanes = []
var player_controlled_rat: Rat
var is_punishing_caught_rats = false

const NUM_RATS = 4
const NUM_LANES = 5
const CAUGHT_PENALTY = 50

func _ready():
	var lane_y_pos = 350
	for i in range(0, NUM_LANES):
		var lane = Lane.create_new(lane_y_pos)
		lanes.append(lane)
		add_child(lane)
		lane_y_pos += 60

	for i in range(0, NUM_RATS):
		var rat = rat_scene.instantiate() as Rat
		rat.rat_name = "Rat " + str(i + 1)
		if i == 0:
			rat.is_player_controlled = true
			player_controlled_rat = rat
		lanes[i].add_rat_to_lane(rat)
		add_child(rat)

	cat.global_position = Vector2(0, 450)

	cat.on_hide.connect(on_cat_hide)
	cat.on_peek.connect(on_cat_peek)
	cat.on_watch.connect(on_cat_watch)

func get_all_rats():
	var rats = []
	for lane in lanes:
		rats += lane.rats_in_lane
	return rats

func is_cat_watching():
	return cat.curr_phase == Cat.Phase.WATCHING

func is_cat_within_watch_buffer():
	return cat.is_watch_buffer_window

func get_all_cpu_rats():
	var rats = []
	for lane in lanes:
		for r in lane.rats_in_lane:
			if !r.is_player_controlled:
				rats.append(r)
	return rats

func on_cat_peek():
	# Position cat
	var left_most_x = INF
	var right_most_x = -INF
	var all_rats = get_all_rats()
	for r in all_rats:
		left_most_x = min(r.global_position.x, left_most_x)
		right_most_x = max(r.global_position.x, right_most_x)
	var midpoint_x = (left_most_x + right_most_x) / 2
	cat.global_position = Vector2(midpoint_x, 400)
	var tween = create_tween()
	tween.tween_property(cat, "global_position", Vector2(midpoint_x, 350), 0.25)
	tween.finished.connect(go_to_next_phase_after_wait_time)

func on_cat_watch():
	var tween = create_tween()
	tween.tween_property(cat, "global_position", Vector2(cat.global_position.x, 250), 0.25)
	var cpu_rats = get_all_cpu_rats()
	for rat in cpu_rats:
		var is_delay = randi_range(0, 1) == 0
		if is_delay:
			var cpu_stop_moving_timer = Timer.new()
			cpu_stop_moving_timer.autostart = true
			cpu_stop_moving_timer.wait_time = 0.5
			cpu_stop_moving_timer.one_shot = true
			var on_timeout = Callable(self, "cpu_stop_moving").bind(rat)
			cpu_stop_moving_timer.timeout.connect(on_timeout)
			add_child(cpu_stop_moving_timer)
		else:
			rat.cpu_move_timer.stop()

	var punish_caught_rats_timer = Timer.new()
	punish_caught_rats_timer.autostart = true
	punish_caught_rats_timer.wait_time = 1
	punish_caught_rats_timer.one_shot = true
	var on_timeout = Callable(self, "process_caught_rats")
	punish_caught_rats_timer.timeout.connect(on_timeout)
	add_child(punish_caught_rats_timer)

func process_caught_rats():
	is_punishing_caught_rats = true
	var caught_rats = get_all_rats().filter(func(r): return r.is_caught)
	push_back_caught_rat(caught_rats, 0)

func push_back_caught_rat(caught_rats, index):
	if index == caught_rats.size():
		go_to_next_phase_after_wait_time()
		return
	var rat_to_push = caught_rats[index]
	var new_x = max(Lane.INITIAL_START_X, rat_to_push.global_position.x - CAUGHT_PENALTY)
	var tween = create_tween()
	tween.tween_property(rat_to_push, "global_position", Vector2(new_x, rat_to_push.global_position.y), 0.25)
	var on_tween_finished = Callable(self, "push_back_caught_rat").bind(caught_rats, index + 1)
	tween.finished.connect(on_tween_finished)

	
func cpu_stop_moving(rat: Rat):
	rat.cpu_move_timer.stop()

func on_cat_hide():
	is_punishing_caught_rats = false
	var tween = create_tween()
	tween.tween_property(cat, "global_position", Vector2(cat.global_position.x, 450), 0.25)
	var cpu_rats = get_all_cpu_rats()
	for rat in cpu_rats:
		# Reset cpu move frequency (to make it more interesting)
		rat.cpu_move_timer.wait_time = float(randi_range(1, 5)) / 10
		rat.cpu_move_timer.start()

	var all_rats = get_all_rats()
	for rat in all_rats:
		rat.reset_caught_state()
	tween.finished.connect(go_to_next_phase_after_wait_time)

func go_to_next_phase_after_wait_time():
	cat.go_to_next_phase()

func _on_finish_body_entered(body):
	if body is Rat:
		var rat = body as Rat
		PlayerVariables.winner_rat_name = rat.rat_name
		get_tree().change_scene_to_file("res://scenes/GameOver.tscn")

