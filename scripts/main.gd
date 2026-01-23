extends Node

signal global_tick

@onready var global_tick_timer: Timer = $GlobalTickTimer
@onready var tilemap: TileMapLayer = $TileMapLayer
@onready var line_2d: Line2D = $Line2D

var placing_bee: bool = false
var bee_path: Array[Vector2i] = []

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
			
	if event.is_action_pressed("place_bee"):
		placing_bee = true
		
	if event.is_action_pressed("left_click") and placing_bee == true:
		try_add_tile()

func _on_tick_timer_timeout() -> void:
	emit_signal("global_tick")
	

	
func try_add_tile():
	var tile = tilemap.local_to_map(tilemap.get_local_mouse_position())
	
	if bee_path.has(tile):
		return

	if bee_path.is_empty():
		bee_path.append(tile)
		highlight(tile)
		return

	var last := bee_path[-1]
	if is_neighbor(last, tile):
		bee_path.append(tile)
		highlight(tile)


func highlight(tile):
	line_2d.add_point(tilemap.local_to_map(tile))
	

func is_neighbor(a: Vector2i, b: Vector2i) -> bool:
	var neighbor_offsets = [
		Vector2i(1, 0), # Right
		Vector2i(1, -1), # Top Right
		Vector2i(0, -1), # Top Left
		Vector2i(-1, 0), # Left
		Vector2i(-1, 1), # Bottom Left
		Vector2i(0, 1) # Bottom Right
	]

	for neighbor in neighbor_offsets:
		if neighbor - a == b:
			return true
	return false
