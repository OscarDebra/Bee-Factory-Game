extends HBoxContainer

var selected_slot: int = 0
var slots: Array

func _ready():
	slots = get_children()
	for i in slots.size():
		slots[i].slot_index = i
	select_slot(0)

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1: select_slot(0)
			KEY_2: select_slot(1)
			KEY_3: select_slot(2)
			KEY_4: select_slot(3)
			KEY_5: select_slot(4)


func select_slot(index: int):
	selected_slot = index
	for i in slots.size():
		slots[i].set_selected(i == index)
