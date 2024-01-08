extends Node2D

class_name SelectionArea

signal changeSelectionArea(position1, position2)


@export var selectionShape : CollisionShape2D
@export var whichShape : Shape2D

# Dictionary because no duplicates and more efficient
var gameNodes : Dictionary



func getNodesInArea(position1 : Vector2, position2 : Vector2):
	setSelectionArea(position1, position2)
	return getCurrentNodes()


func getCurrentNodes() -> Array[GameNode]:
	var outputNodes : Array[GameNode] = []
	for gameNode in gameNodes.keys():
		outputNodes.append(gameNode.get_parent())
	
	return outputNodes


func setSelectionArea(position1 : Vector2, position2 : Vector2):
	var topLeft := findTopLeftMostCorner(position1, position2)
	var bottomRight := findBottomRightMostCorner(position1, position2)
	# Find TopLeft-most corner and set color rect and selection area same
	position = findTopLeftMostCorner(position1, position2)
	whichShape.size = bottomRight - topLeft
	$ColorRect.size = bottomRight - topLeft
	
	selectionShape.shape = whichShape


func findTopLeftMostCorner(position1 : Vector2, position2 : Vector2) -> Vector2:
	var x = min(position1.x, position2.x)
	var y = min(position1.y, position2.y)
	return Vector2(x,y)


func findBottomRightMostCorner(position1 : Vector2, position2 : Vector2) -> Vector2:
	var x = max(position1.x, position2.x)
	var y = max(position1.y, position2.y)
	return Vector2(x,y)


func selectionEntered(area):
	gameNodes[area] = 0.0


func selectionExited(area):
	gameNodes.erase(area)
