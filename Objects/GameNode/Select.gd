extends Area2D

signal selectionChanged(selected : bool)
signal onHovered(hovered : bool)

var isSelected := false : set = setSelected
var isHovered := false : set = setHovered

func setHovered(hovered : bool):
	isHovered = hovered
	onHovered.emit(isHovered)


func setSelected(selected : bool):
	isSelected = selected
	selectionChanged.emit(isSelected)
