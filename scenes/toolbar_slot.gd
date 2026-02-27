extends PanelContainer

var slot_index: int


func set_selected(is_selected: bool):
	print("Bongus")


func _on_background_pressed() -> void:
	get_parent().select_slot(slot_index)
