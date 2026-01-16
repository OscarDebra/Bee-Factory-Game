extends Camera2D

# Camera settings
@export var zoom_speed: float = 0.01
@export var min_zoom: float = 0.5
@export var max_zoom: float = 10
@export var drag_sensitivity: float = 40.0
@export var default_zoom: float = 10.0

func _ready():
	make_current()
	zoom_camera(default_zoom)

func _input(event):
	if event is InputEventPanGesture:
		# Touchpad two-finger pan
		position += event.delta * drag_sensitivity / zoom.x
	
	if event is InputEventMagnifyGesture:
		# Touchpad pinch to zoom
		zoom_camera(event.factor)


func zoom_camera(factor: float):
	var new_zoom = zoom * factor
	# Clamp zoom levels
	new_zoom.x = clamp(new_zoom.x, min_zoom, max_zoom)
	new_zoom.y = clamp(new_zoom.y, min_zoom, max_zoom)
	zoom = new_zoom
