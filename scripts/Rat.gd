class_name Rat
extends Node2D

@onready var game = get_node("/root/Main") as Game
var rat_name = ""
var is_player_controlled = false
var num_key_presses = 0
var cpu_move_timer
var is_caught = false


const MOVE_BUFFER_LIMIT = 3
var move_buffer_count = 0

func _ready():
	if !is_player_controlled:
		cpu_move_timer = Timer.new()
		cpu_move_timer.wait_time = float(randi_range(1, 5)) / 10
		cpu_move_timer.autostart = true
		var on_timeout = Callable(self, "on_move_tick")
		cpu_move_timer.timeout.connect(on_timeout)
		add_child(cpu_move_timer)

func _input(event):
	if is_player_controlled and !game.is_punishing_caught_rats:
		var just_pressed = event.is_pressed() and not event.is_echo()
		if Input.is_key_pressed(KEY_SPACE) and just_pressed:
			global_position.x += 2
			if game.is_cat_watching() and !game.is_cat_within_watch_buffer():
				is_caught = true
				self.modulate = Color(1, 0, 0)

func on_move_tick():
	if !game.is_punishing_caught_rats:
		global_position.x += 2
		if game.is_cat_watching() and !game.is_cat_within_watch_buffer():
			is_caught = true
			self.modulate = Color(1, 0, 0)

func reset_caught_state():
	is_caught = false
	self.modulate = Color(1, 1, 1)
	move_buffer_count = 0