extends PanelContainer

var slot_index: int


func _ready() -> void:
	$background.pressed.connect(_on_pressed)


func _on_pressed() -> void:
	get_parent().select_slot(slot_index)
