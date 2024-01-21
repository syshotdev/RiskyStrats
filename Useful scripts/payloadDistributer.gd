extends Node

class_name PayloadDistributer


# Simple. Pathfinds a way to endNode, asks startNode to send a unit with the route and units
func sendPayload(startNode : GameNode, endNode : GameNode, unit : Unit):
	var route = pathfind(startNode, endNode)
	
	var roadUnit = RoadUnit.new(unit.currentColor, unit.units)
	roadUnit.units = unit.units
	roadUnit.route = route
	
	startNode.processRoadUnit(roadUnit)


# Returns all the nodes TO the end, not including the current node.
func pathfind(startNode : GameNode, endNode : GameNode) -> Array[GameNode]:
	var currentColor = startNode.currentColor
	
	var toCheck : Array[GameNode] = [startNode]
	var checked : Array[GameNode] = []
	
	# Simple, records the node that this node took to get here. Used to reconstruct path back
	# Key node, value nodeItCameFrom
	var nodeParent : Dictionary = {}
	
	while toCheck.size() > 0:
		var lowestCostIndex = findLeastCostNode(startNode, endNode, toCheck)
		
		var currentNode = toCheck[lowestCostIndex]
		
		
		# If we've found the goal, end search
		if(currentNode == endNode):
			return calculatePathBack(startNode,endNode,nodeParent) # Return the array
		
		# Remove current node from the search
		checked.append(currentNode)
		toCheck.remove_at(lowestCostIndex)
		
		# To fix not able to send to different color.
		# If current node is not our node, don't include in path search.
		if(currentNode.currentColor != startNode.currentColor):
			continue
		
		for neighbor in currentNode.neigbors:
			# If it's been checked or it's not our color, don't check it
			if neighbor in checked:
				continue
			
			toCheck.append(neighbor)
			# Parent = currentNode, because current node neigbors is this
			nodeParent[neighbor] = currentNode
	
	# Return nothing because there was no path
	return []


func calculatePathBack(endNode : GameNode, nodeParent : Dictionary) -> Array[GameNode]:
	var currentNode := endNode
	var route : Array[GameNode] = []
	
	while currentNode in nodeParent:
		route.push_front(currentNode)
		currentNode = nodeParent[currentNode]
	
	print(route)
	return route


# Returns the lowest cost node from an array
func findLeastCostNode(startNode : GameNode, endNode : GameNode, gameNodesToCheck : Array[GameNode]) -> int:
	var lowestCost : float = 9999999999
	var lowestCostIndex : int = 0
	
	for nodeIndex in range(gameNodesToCheck.size()):
		var node = gameNodesToCheck[nodeIndex]
		var nodeCost = calculateCostOfNode(node, startNode, endNode)
		
		if(nodeCost < lowestCost):
			lowestCostIndex = nodeIndex
			lowestCost = nodeCost
	
	return lowestCostIndex


# Just the distance between node1 and node2
func calculateCostOfNode(node : GameNode, startNode : GameNode, endNode : GameNode) -> float:
	var fromStartCost = node.position.distance_to(startNode.position)
	var fromEndCost = node.position.distance_to(endNode.position)
	return fromStartCost + fromEndCost

