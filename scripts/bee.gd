extends Node2D

@onready var my_tilemap = get_parent().get_node("TileMapLayer")

const HEX_DIRS := [
	Vector2i(1, 0),
	Vector2i(1, -1),
	Vector2i(0, -1),
	Vector2i(-1, 0),
	Vector2i(-1, 1),
	Vector2i(0, 1),
]

const path := [
	Vector2i(1, 0),
	Vector2i(1, 0),
	Vector2i(0, -1),
	Vector2i(-1, -1),
	Vector2i(-1, 1),
	Vector2i(0, 1),
]

var path_index: int = 0
var map_position := Vector2i(0, 0)

var is_moving := false
var move_progress := 0.0
var move_duration := 0.2
var start_position := Vector2.ZERO
var target_position := Vector2.ZERO

func _ready() -> void:
	get_tree().get_root().get_node("main").global_tick.connect(_on_global_tick)
	global_position = my_tilemap.map_to_local(Vector2i(0, 0))


func _process(delta) -> void:
	if is_moving:
		move_progress += delta / move_duration
		
		if move_progress >= 1.0:
			# Snap to final position
			global_position = target_position
			start_position = target_position
			is_moving = false
			move_progress = 0.0
		else:
			# Smooth interpolation
			global_position = start_position.lerp(target_position, move_progress)

func _on_global_tick():

	if path_index == path.size():
		path_index = 0
	
	map_position += path[path_index]
	
	start_position = global_position
	target_position = my_tilemap.map_to_local(map_position)
	is_moving = true
	path_index += 1
