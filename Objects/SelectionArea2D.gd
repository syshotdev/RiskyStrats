extends Area2D

signal selectionToggled(selection)

@export var exclusive = true
# Idk the selection adction yet
@export var selectionAction = 0

var selection : bool = true
var selected : bool = false

func setSelected(value : bool):
	if selection:
		makeExclusive()
		add_to_group("selected")
	else:
		remove_from_group("selected")
	selected = selection
	emit_signal("selectionToggled", selected)


func makeExclusive():
	if not selected:
		return
	get_tree().call_group("selected", "setSelected", false)


func _input_event(viewport, event, shape_idx):
	if event.is_action_pressed(selectionAction):
		setSelected(!selected)
