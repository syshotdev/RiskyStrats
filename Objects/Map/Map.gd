extends Node2D

class_name Map

@export var defaultNodeColor : GameColors.colors

# Generation
const genRate : float = 5.0 # Rate default node generates per second
var effectiveness : float = 1.0 # Multiplier for genRate

var killRate : float = 0.02 # The rate at which one soldier can kill another per unit of time

var roads : Array
var nodes : Array

func _ready():
	initMap()


# Meant to make the entire game work on a clock rather than _process()
func tick(delta : float):
	for road in roads:
		road.moveAllRoadUnits(delta)
	for node in nodes:
		node.tick(delta)


# May not be needed, but gets the nodes and roads in this current map
func initMap():
	roads = find_child("Roads").get_children()
	nodes = find_child("Nodes").get_children()
	
	for road in roads:
		setNodeNeighbors(road)
	
	for node in nodes:
		node.addUnit(Unit.new(defaultNodeColor, 25))
	
	var nodeNumber := 6
	if(nodes.size() > nodeNumber):
		nodes[7].addUnit(Unit.new(GameColors.colors.GREEN, 40))
		nodes[nodeNumber].addUnit(Unit.new(GameColors.colors.GREEN, 40))


# Gets the road's connections and sets themselves as neighbors
func setNodeNeighbors(road : Road):
	var node1 = road.node1
	var node2 = road.node2
	node1.addNeighbor(node2, road)
	node2.addNeighbor(node1, road)


# Sends payloads to destination with some ifs
func orderSendPayload(nodes : Array[GameNode], target : GameNode, unit : Unit):
	for node in nodes:
		var color := unit.color
		
		# If this isn't our node, don't send our unit
		if(color != node.color):
			continue
		
		var maxUnitsCanSend : float = min(node.unitAmounts[color], unit.units) - 1
		
		# If can't send units, don't
		if(maxUnitsCanSend <= 0):
			continue
		
		var newUnit : Unit = Unit.new(color, maxUnitsCanSend)
		newUnit.units = maxUnitsCanSend
		node.unitAmounts[color] -= maxUnitsCanSend
		
		sendPayload(node, target, newUnit)


func orderBuyBuilding(node : GameNode, type : GameTypes.buildingType) -> bool:
	return node.buyBuildingType(type)


# Simple. Pathfinds a way to endNode, asks startNode to send a unit with the route and units
func sendPayload(startNode : GameNode, endNode : GameNode, unit : Unit):
	var route = pathfind(startNode, endNode)
	
	var roadUnit = RoadUnit.new(unit.color, unit.units)
	roadUnit.units = unit.units
	roadUnit.route = route
	
	startNode.processRoadUnit(roadUnit)


# Returns all the nodes TO the end, not including the current node.
func pathfind(startNode : GameNode, endNode : GameNode) -> Array[GameNode]:
	var color = startNode.color
	
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
			return calculatePathBack(endNode,nodeParent) # Return the array
		
		# Remove current node from the search
		checked.append(currentNode)
		toCheck.remove_at(lowestCostIndex)
		
		# To fix not able to send to different color.
		# If current node is not our node, don't include in path search.
		if(currentNode.color != startNode.color):
			continue
		
		for neighbor in currentNode.neighbors:
			# If it's been checked or it's not our color, don't check it
			if neighbor in checked:
				continue
			
			toCheck.append(neighbor)
			# Parent = currentNode, because current node neighbors is this
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
func findLeastCostNode(startNode : GameNode, endNode : GameNode, nodesToCheck : Array[GameNode]) -> int:
	var lowestCost : float = 9999999999
	var lowestCostIndex : int = 0
	
	for nodeIndex in range(nodesToCheck.size()):
		var node = nodesToCheck[nodeIndex]
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
