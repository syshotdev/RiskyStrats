extends Area2D

class_name HoveredNode

@export var checkingArea : CollisionShape2D

var nodesInArea : Dictionary

func getHoveredNode(positionToCheck : Vector2) -> GameNode:
	checkingArea.position = positionToCheck
	
	if(nodesInArea.size() > 0):
		# Get first node in array
		return nodesInArea.keys()[0]
	
	return null

# Add to the "hovered" array (To be selected later)
func areaEntered(area):
	var node = getParentFromArea(area)
	
	if(node == null):
		return
	
	nodesInArea[node] = 0


func areaExited(area):
	var node = getParentFromArea(area)
	
	if(node == null):
		return
	
	nodesInArea.erase(node)


func getParentFromArea(area : Area2D) -> GameNode:
	var node = area.get_parent()
	
	if(node is GameNode):
		return node
	
	return null
