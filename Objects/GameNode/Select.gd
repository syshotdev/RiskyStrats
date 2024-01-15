extends Area2D

signal selectionChanged(selected : bool)
signal onHovered()

var isSelected := false
var hovered := false 

func setHovered(hovered : bool):
	hovered = false


func setSelected(selected : bool):
	isSelected = selected
	selectionChanged.emit(isSelected)
