extends Node

signal global_tick

@onready var global_tick_timer: Timer = $GlobalTickTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_tick_timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _input(event):
	if event.is_action_pressed("ui_fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _on_tick_timer_timeout() -> void:
	emit_signal("global_tick")
