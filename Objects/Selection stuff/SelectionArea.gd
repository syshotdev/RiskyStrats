extends Node2D

class_name SelectionArea

signal changeSelectionArea(position1, position2)


@export var selectionVisual : Node2D
@export var selectionShape : CollisionShape2D

enum selectionTypes{
	CIRCLE,
	RECTANGLE
}

# The shape of the selection area
var shape : Shape2D

# Dictionary because no duplicates and more efficient
var gameNodes : Dictionary


func _ready():
	changeSelectionType(selectionTypes.RECTANGLE)

# I don't know why I need this (to create selection shapes?)
func changeSelectionType(type : selectionTypes):
	if type == selectionTypes.RECTANGLE:
		shape = RectangleShape2D.new()
	elif type == selectionTypes.CIRCLE:
		shape = CircleShape2D.new()


func setSelectionArea(position1 : Vector2, position2 : Vector2):
	# Logic: If rectangle, do things rectangle needs like selection box. Circle, new circle object
	if(shape is RectangleShape2D):
		rectSelectionArea(position1, position2)
	else: # Circle selection area
		circleSelectionArea(position1, position2)
	
	selectionVisual.updateShape(shape)
	selectionShape.shape = shape

# Does all the things to make a circle shape
func circleSelectionArea(position1 : Vector2, position2 : Vector2):
	var centerOfCircle = position1
	var radius = position1.distance_to(position2)
	
	# Set this selection area to center of circle
	position = centerOfCircle
	# Shape is circle, set the radius
	shape.radius = radius


# Does all the things to create a selection the size of a rectangle
func rectSelectionArea(position1 : Vector2, position2 : Vector2):
	var topLeft := findTopLeftMostCorner(position1, position2)
	var bottomRight := findBottomRightMostCorner(position1, position2)
	var rectArea := bottomRight - topLeft
	
	position = topLeft
	shape.size = rectArea
	# Offset the thing so it's actually where visual rectangle is
	selectionShape.position = rectArea/2

# For rectangle
func findTopLeftMostCorner(position1 : Vector2, position2 : Vector2) -> Vector2:
	var x = min(position1.x, position2.x)
	var y = min(position1.y, position2.y)
	return Vector2(x,y)

# For rectangle
func findBottomRightMostCorner(position1 : Vector2, position2 : Vector2) -> Vector2:
	var x = max(position1.x, position2.x)
	var y = max(position1.y, position2.y)
	return Vector2(x,y)


# Gets the current amount of nodes in an area
func getNodesInArea(position1 : Vector2, position2 : Vector2):
	setSelectionArea(position1, position2)
	return getCurrentNodes()


func getCurrentNodes() -> Array[GameNode]:
	var outputNodes : Array[GameNode] = []
	for gameNode in gameNodes.keys():
		outputNodes.append(gameNode.get_parent())
	
	return outputNodes


func selectionEntered(area):
	gameNodes[area] = 0.0


func selectionExited(area):
	gameNodes.erase(area)
