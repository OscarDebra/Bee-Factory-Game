extends Node2D
@onready var my_tilemap = get_parent().get_node("TileMapLayer")
@onready var bee_air_1 = $bee_air_1
@onready var bee_air_2 = $bee_air_2

var path : Array[Vector2i] = []  # Changed from const to var with type
var move_tick := false
var path_index := 0
var map_position := Vector2i(0, 0)
var is_moving : bool = false
var move_progress := 0.0
var move_duration := 0.2
var start_position := Vector2.ZERO
var target_position := Vector2.ZERO
var is_rotating : bool = false
var rotation_progress := 0.0
var rotation_duration := 0.2
var start_rotation := 0.0
var target_rotation := 0.0

func _ready() -> void:
	get_tree().get_root().get_node("main").global_move_tick.connect(_on_global_move_tick)
	get_tree().get_root().get_node("main").global_rotate_tick.connect(_on_global_rotate_tick)
	get_tree().get_root().get_node("main").global_animation_tick.connect(_on_global_animation_tick)
	map_position = my_tilemap.local_to_map(global_position)

func _process(delta) -> void:
	if is_rotating:
		rotation_progress += delta / rotation_duration
		
		if rotation_progress >= 1.0:
			rotation = target_rotation
			start_rotation = target_rotation
			is_rotating = false
			rotation_progress = 0.0
		else:
			rotation = lerp_angle(start_rotation, target_rotation, rotation_progress)
	
	elif is_moving:  # Only move after rotation is complete
		move_progress += delta / move_duration
		
		if move_progress >= 1.0:
			global_position = target_position
			start_position = target_position
			is_moving = false
			move_progress = 0.0
		else:
			global_position = start_position.lerp(target_position, move_progress)


func _on_global_move_tick():
	if path_index == path.size():
		path_index = 0
	
	map_position += path[path_index]
	start_position = global_position
	target_position = my_tilemap.map_to_local(map_position)
	is_moving = true
	path_index += 1
	move_tick = false


func _on_global_rotate_tick():
	var next_index = path_index % path.size()
	var next_direction = path[next_index]
	var future_position = my_tilemap.map_to_local(map_position + next_direction)
	var dir = (future_position - global_position).normalized()
	
	start_rotation = rotation
	target_rotation = dir.angle()
	is_rotating = true
	rotation_progress = 0.0
	move_tick = true

func _on_global_animation_tick():
	bee_air_1.visible = !bee_air_1.visible
	bee_air_2.visible = !bee_air_2.visible
	
