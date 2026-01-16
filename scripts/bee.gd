extends Node2D

const HEX_DIRS = [
	Vector2i(1, 0),
	Vector2i(1, -1),
	Vector2i(0, -1),
	Vector2i(-1, 0),
	Vector2i(-1, 1),
	Vector2i(0, 1),
]

@onready var my_tilemap = get_parent().get_node("TileMapLayer")

func _ready() -> void:
	global_position = my_tilemap.map_to_local(HEX_DIRS[1])


func _process(_delta) -> void:
	pass
