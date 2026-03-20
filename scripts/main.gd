extends Node
signal global_move_tick
signal global_rotate_tick
signal global_animation_tick(frame_num: int)

@onready var global_tick_timer: Timer = $GlobalTickTimer
@onready var tilemap: TileMapLayer = $TileMapLayer
@onready var line_2d: Line2D = $Line2D

var placing_bee: bool = false
var bee_path: Array[Vector2i] = []
var bee_scene = preload("res://scenes/bee.tscn")
var move_tick = true
var tick_index = 0
var bee_info = []
var bee_count: int = 0
var bees = {}
var incoming_bee = false
var frame_num: int = 0
var stuck_bees: Array = []
var occupied_positions: Array = []

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
			incoming_bee = true
	
	if event.is_action_pressed("left_click") and placing_bee:
		try_add_tile()
	
	if event.is_action_pressed("ui_cancel") and placing_bee:
		# Cancel placement
		cancel_bee_placement()

func _on_global_tick_timer_timeout() -> void:
	if (tick_index == 3): # Move / rotate every 4 ticks

		if (move_tick):
			emit_signal("global_move_tick")
		else:
			if incoming_bee:
				confirm_bee_placement()
				incoming_bee = false

			emit_signal("global_rotate_tick")

		move_tick = !move_tick
		tick_index = 0

	tick_index += 1

	signal_bee_wing_flap()



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
		
	if bee_path[0] in occupied_positions:
		print("Bee is overlapping spawn position")
		cancel_bee_placement()
		return


	var relative_path: Array[Vector2i] = []
	for i in range(bee_path.size()):
		var current = bee_path[i]
		var next = bee_path[(i + 1) % bee_path.size()]
		relative_path.append(next - current)
	
	# Spawn the bee
	var bee = bee_scene.instantiate()
	bee.bee_next_pos.connect(_on_bee_next_pos)
	bee.bee_removed.connect(_on_bee_removed)
	bee_count += 1
	add_child(bee)
	bees[bee.get_instance_id()] = bee
	occupied_positions.append(bee_path[0])
	
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



func _on_bee_next_pos(id: int, current_pos: Vector2i, next_pos: Vector2i):
	bee_info.append({"id": id, "current_pos": current_pos, "next_pos": next_pos})
	
	if bee_info.size() >= bee_count:
		resolve_collisions()


func resolve_collisions():
	var losers = []
	
	# Head-on collisions
	var pos_map = {}
	for entry in bee_info:
		pos_map[entry["current_pos"]] = entry
	
	for entry in bee_info:
		if entry["next_pos"] in pos_map:
			var other = pos_map[entry["next_pos"]]
			if other["next_pos"] == entry["current_pos"]:
				if entry["id"] not in losers:
					losers.append(entry["id"])
				if other["id"] not in losers:
					losers.append(other["id"])
	
	# Iteratively resolve until stable
	var prev_loser_count = -1
	while prev_loser_count != losers.size():
		prev_loser_count = losers.size()
		
		# Build seen from non-losers only
		var seen = {}
		for entry in bee_info:
			if entry["id"] in losers:
				continue
			var pos = entry["next_pos"]
			if pos not in seen:
				seen[pos] = []
			seen[pos].append(entry["id"])
		
		# 2+ bees targeting same tile — pick winner that can actually move
		for pos in seen:
			if seen[pos].size() > 1:
				var ids = seen[pos].duplicate()
				# Find candidates that aren't blocked themselves
				var free_candidates = ids.filter(func(id):
					var e = bee_info.filter(func(x): return x["id"] == id)[0]
					# A bee is free if its next_pos is not the current_pos of a loser
					for other in bee_info:
						if other["id"] in losers and e["next_pos"] == other["current_pos"]:
							return false
					return true
				)
				# Pick winner from free candidates if any, otherwise just pick random
				var winner
				if free_candidates.size() > 0:
					winner = free_candidates.pick_random()
				else:
					winner = ids.pick_random()
				ids.erase(winner)
				for id in ids:
					if id not in losers:
						losers.append(id)

		# Bee walking into a loser's current tile becomes a loser
		for entry in bee_info:
			if entry["id"] in losers:
				continue
			for other in bee_info:
				if other["id"] in losers and entry["next_pos"] == other["current_pos"]:
					if entry["id"] not in losers:
						losers.append(entry["id"])
					break
	
	for entry in bee_info:
		if entry["id"] not in losers:
			bees[entry["id"]].move()
			occupied_positions.erase(entry["current_pos"])
			occupied_positions.append(entry["next_pos"])
	
	bee_info.clear()


func signal_bee_wing_flap():
	frame_num += 1
	if frame_num > 1:
		frame_num = 0

	global_animation_tick.emit(frame_num)


func _on_bee_removed(id: int, pos: Vector2i) -> void:
	bees.erase(id)
	occupied_positions.erase(pos)
	bee_count -= 1
	# Remove any pending bee_info entries for this bee
	bee_info = bee_info.filter(func(e): return e["id"] != id)
