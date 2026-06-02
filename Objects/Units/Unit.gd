extends Node2D

class_name Unit

var units : float = 0.0
var color : GameColors.colors

func _init(color : GameColors.colors, initUnits : float = 0):
	self.color = color
	self.units = initUnits
