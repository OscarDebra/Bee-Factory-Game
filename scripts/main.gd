extends Node
signal global_move_tick
signal global_rotate_tick
@onready var global_tick_timer: Timer = $GlobalTickTimer
@onready var tilemap: TileMapLayer = $TileMapLayer
@onready var line_2d: Line2D = $Line2D

var placing_bee: bool = false
var bee_path: Array[Vector2i] = []
var bee_scene = preload("res://scenes/bee.tscn")
var move_tick = true

func _ready() -> void:
	global_tick_timer.start()

func _process(_delta: float) -> void:
	pass

func _input(event):
	if event.is_action_pressed("ui_fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	if event.is_action_pressed("place_bee"):
		if not placing_bee:
			# Start placing
			placing_bee = true
			bee_path.clear()
			line_2d.clear_points()
		else:
			confirm_bee_placement()
	
	if event.is_action_pressed("left_click") and placing_bee:
		try_add_tile()
	
	if event.is_action_pressed("ui_cancel") and placing_bee:
		# Cancel placement
		cancel_bee_placement()

func _on_global_tick_timer_timeout() -> void:
	if (move_tick):
		emit_signal("global_move_tick")
	else:
		emit_signal("global_rotate_tick")
	
	move_tick = !move_tick

func try_add_tile():
	var tile = tilemap.local_to_map(tilemap.get_local_mouse_position())
	
	
	if bee_path.is_empty():
		bee_path.append(tile)
		highlight(tile)
		return
	
	var last := bee_path[-1]
	if is_neighbor(last, tile):
		bee_path.append(tile)
		highlight(tile)

func highlight(tile):
	line_2d.add_point(tilemap.map_to_local(tile))

func confirm_bee_placement():
	if bee_path.size() < 3:
		print("Path too short! Need at least 3 tiles for a cycle.")
		cancel_bee_placement()
		return
	
	if not is_neighbor(bee_path[-1], bee_path[0]):
		print("Path must form a cycle! Last tile must be adjacent to first tile.")
		cancel_bee_placement()
		return
	

	var relative_path: Array[Vector2i] = []
	for i in range(bee_path.size()):
		var current = bee_path[i]
		var next = bee_path[(i + 1) % bee_path.size()]
		relative_path.append(next - current)
	
	# Spawn the bee
	var bee = bee_scene.instantiate()
	add_child(bee)
	
	bee.global_position = tilemap.map_to_local(bee_path[0])
	bee.map_position = bee_path[0]
	bee.path = relative_path
	bee.path_index = 0
	
	placing_bee = false
	bee_path.clear()
	line_2d.clear_points()
	
	print("Bee placed with cycle path!")

func cancel_bee_placement():
	placing_bee = false
	bee_path.clear()
	line_2d.clear_points()
	print("Bee placement cancelled.")

func is_neighbor(a: Vector2i, b: Vector2i) -> bool:
	var neighbor_offsets_even = [
		Vector2i(1, 0),   # Bottom Right
		Vector2i(-1, 0),  # Bottom Left
		Vector2i(1, -1), # Top Right
		Vector2i(-1, -1),  # Top Left
		Vector2i(0, -1),  # Up
		Vector2i(0, 1)    # Down
	]
	
	var neighbor_offsets_odd = [
		Vector2i(1, 1),  # Bottom Right
		Vector2i(-1, 1),  # Bottom Left
		Vector2i(1, 0),  # Top Right
		Vector2i(-1, 0),  # Top Left
		Vector2i(0, -1),   # Up
		Vector2i(0, 1)    # Down
	]
	
	# Determine which offset set to use based on the row
	var offsets = neighbor_offsets_even if a.x % 2 == 0 else neighbor_offsets_odd
	
	for neighbor in offsets:
		if a + neighbor == b:
			return true
	return false
