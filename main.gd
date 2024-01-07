extends Node2D

var roads
var nodes

func _ready():
	roads = find_child("Roads").get_children()
	nodes = find_child("Nodes").get_children()
	
	for road in roads:
		setRoadNodeNeighbors(road)
	
	for node in nodes:
		#print(node.neigbors)
		#print(node.neigborRoads)
		pass
	
	var startNode = nodes[1]
	var endNode = nodes[2]
	sendPayload(startNode,endNode,Unit.new(GameColors.colors.BLUE, 30))


# Simple. Pathfinds a way to endNode, asks startNode to send a unit with the route and units, colors later.
func sendPayload(startNode : GameNode, endNode : GameNode, unit : Unit):
	var route = pathfind(startNode, endNode)
	
	var roadUnit = RoadUnit.new(unit.currentColor, unit.units)
	roadUnit.units = unit.units
	roadUnit.route = route
	
	startNode.processRoadUnit(roadUnit)


# Gets the road's node1 and node2 and sets themselves as neighbors
func setRoadNodeNeighbors(road : Road):
	var node1 = road.node1
	var node2 = road.node2
	node1.addNeigbor(node2,road)
	node2.addNeigbor(node1,road)


# Returns all the nodes TO the end, not including the current node.
func pathfind(startNode : GameNode, endNode : GameNode) -> Array[GameNode]:
	var currentColor = startNode.currentColor
	
	var toCheck : Array[GameNode] = [startNode]
	var checked : Array[GameNode] = []
	
	while toCheck.size() > 0:
		var currentNode = findLeastCostNode(startNode, endNode, toCheck) # Should return index of lowest cost node
		
		if(currentNode == endNode):
			return [] # Calculate path as search has ended
		
		checked.append(currentNode)
		toCheck.remove_at(0) # Should remove index of current node
		
		for neighbor in currentNode.neigbors:
			# If it's been checked or it's not our color, don't check it
			if neighbor in checked or neighbor.currentColor != currentColor:
				continue
			
			toCheck.append(neighbor)
	
	
	return []


# Returns the lowest cost node from an array
func findLeastCostNode(startNode : GameNode, endNode : GameNode, gameNodesToCheck : Array[GameNode]):
	var lowestCost : float = 0
	var lowestNode : GameNode
	
	for node in gameNodesToCheck:
		var fromStartCost = calculateCostOfNode(node, startNode)
		var toEndCost = calculateCostOfNode(node, endNode)
		var total = fromStartCost + toEndCost
		
		if(total < lowestCost):
			lowestNode = node
			lowestCost = total
	
	
	return lowestNode


# Just the distance between node1 and node2
func calculateCostOfNode(startNode : GameNode, endNode : GameNode) -> float:
	return node1.global_position.distance_to(node2.global_position)
