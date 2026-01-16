extends Camera2D

# Camera settings
@export var zoom_speed: float = 0.01
@export var min_zoom: float = 0.5
@export var max_zoom: float = 10
@export var drag_sensitivity: float = 1.0

# State variables
var is_dragging: bool = false
var drag_start_position: Vector2
var camera_start_position: Vector2

func _ready():
	make_current()

func _input(event):
	# Handle mouse wheel zoom (touchpad pinch/scroll)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_camera(1.0 + zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_camera(1.0 - zoom_speed)
		
		# Start dragging with middle or right mouse button
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				start_drag(event.position)
			else:
				stop_drag()
	
	# Handle mouse motion for dragging
	if event is InputEventMouseMotion and is_dragging:
		update_drag(event.position)
	
	# Alternative: Handle touchpad gestures (Godot 4.2+)
	if event is InputEventPanGesture:
		# Touchpad two-finger pan
		position -= event.delta * drag_sensitivity / zoom.x
	
	if event is InputEventMagnifyGesture:
		# Touchpad pinch to zoom
		zoom_camera(event.factor)

func start_drag(mouse_pos: Vector2):
	is_dragging = true
	drag_start_position = mouse_pos
	camera_start_position = position

func stop_drag():
	is_dragging = false

func update_drag(mouse_pos: Vector2):
	var drag_delta = (drag_start_position - mouse_pos) * drag_sensitivity / zoom.x
	position = camera_start_position + drag_delta

func zoom_camera(factor: float):
	var new_zoom = zoom * factor
	# Clamp zoom levels
	new_zoom.x = clamp(new_zoom.x, min_zoom, max_zoom)
	new_zoom.y = clamp(new_zoom.y, min_zoom, max_zoom)
	zoom = new_zoom
