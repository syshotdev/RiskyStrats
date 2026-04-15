extends Node2D


@export var node1 : GameNode
@export var node2 : GameNode

@export var color : Color
@export var shadowColor : Color

@export var thickness : int = 5

var pixelsPerSecond : float = 20


func _draw():
	drawActualLine()

func drawActualLine():
	var pos1 := node1.position - position
	var pos2 := node2.position - position
	
	var offset = Vector2(0,thickness/2)
	
	# Draw shadow first because it's not ontop
	drawLineShadow(pos1 + offset, pos2 + offset)
	
	# Draw actual line now
	draw_line(pos1, pos2, color, thickness)



func drawLineShadow(from : Vector2, to : Vector2):
	draw_line(from, to, shadowColor, thickness)
