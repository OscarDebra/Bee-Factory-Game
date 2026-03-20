extends Area2D

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_pickable = true  # Make sure this is enabled

func _on_mouse_entered():
	modulate = Color(0.013, 0.013, 0.013, 1.0)  # Brighten on hover

func _on_mouse_exited():
	modulate = Color(1, 1, 1)  # Reset
