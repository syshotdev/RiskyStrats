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
	
	var startNode = nodes[0]
	var endNode = nodes[4]
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
		
		for neighbor in currentNode.neigbors:
			print(neighbor)
			# If it's been checked or it's not our color, don't check it
			if neighbor in checked or neighbor.currentColor != currentColor:
				continue
			
			toCheck.append(neighbor)
			# Parent = currentNode, because current node neigbors is this
			nodeParent[neighbor] = currentNode
	
	# Return nothing because there was no path
	return []


func calculatePathBack(startNode : GameNode, endNode : GameNode, nodeParent : Dictionary) -> Array[GameNode]:
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
