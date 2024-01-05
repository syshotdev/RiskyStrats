extends Node2D

class_name Unit

var units : float = 0.0
var currentColor : GameColors.colors

func _init(color : GameColors.colors):
	currentColor = color
