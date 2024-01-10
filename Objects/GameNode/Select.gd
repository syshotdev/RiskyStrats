extends Area2D

signal selectionChanged(selected : bool)

var isSelected = false

func setSelected(selected : bool):
	isSelected = selected
	selectionChanged.emit(isSelected)
