@tool
extends Node2D

class_name ShapeVisualizer

enum shapes{
	CIRCLE,
	HOLLOW_CIRCLE,
	LINE,
}

@export var defaultVisiblity : bool = true
@export var shapeToDraw : shapes
@export var color : Color
@export var canvasLayer : int = 0

@export var thickness : int
@export var radius : int
# For road
@export var to : Vector2

func _ready():
	visible = defaultVisiblity


func _draw():
	if(shapeToDraw == shapes.CIRCLE):
		drawCircle(radius, color)
	elif(shapeToDraw == shapes.HOLLOW_CIRCLE):
		drawHollowCircle(radius, thickness, color)
	elif(shapeToDraw == shapes.LINE):
		drawLine(position, to)


func drawLine(pos1, pos2):
	draw_line(pos1, pos2, color, thickness)


func drawCircle(radius : int, color : Color):
	draw_circle(position, radius, color)


func drawHollowCircle(radius : int, thickness : int, color : Color):
	drawCircle(radius, color)
	# Draw circle to mask out the first circle to make hollow
	#drawCircle(radius - thickness, Color(color, 0))
