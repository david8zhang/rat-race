class_name Cat
extends Node2D

enum Phase {
	HIDING,
	PEEKING,
	WATCHING
}

var switch_phase_timer: Timer
var curr_phase = Phase.HIDING

signal on_peek()
signal on_hide()
signal on_watch()

func _ready():
	# Set timer for next phase switch
	switch_phase_timer = Timer.new()
	switch_phase_timer.wait_time = randi_range(2, 5)
	switch_phase_timer.one_shot = true
	var on_timeout = Callable(self, "handle_phase_switch")
	switch_phase_timer.timeout.connect(on_timeout)
	add_child(switch_phase_timer)
	switch_phase_timer.start()

func handle_phase_switch():
	var new_wait_time = 0
	var prev_phase = curr_phase
	if prev_phase == Phase.HIDING:
		curr_phase = Phase.PEEKING
		new_wait_time = randi_range(1, 3)
		on_peek.emit()
	elif prev_phase == Phase.PEEKING:
		curr_phase = Phase.WATCHING
		new_wait_time = randi_range(3, 5)
		on_watch.emit()
	elif prev_phase == Phase.WATCHING:
		new_wait_time = randi_range(4, 6)
		curr_phase = Phase.HIDING
		on_hide.emit()

	# Set timer for next phase switch
	switch_phase_timer.wait_time = new_wait_time
	switch_phase_timer.start()
