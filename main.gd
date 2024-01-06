extends Node2D

var roads
var nodes

func _ready():
	roads = find_child("Roads").get_children()
	nodes = find_child("Nodes").get_children()
	
	for road in roads:
		setRoadNodeNeighbors(road)
	
	for node in nodes:
		print(node.neigbors)


# Simple. Pathfinds a way to endNode, asks startNode to send a unit with the route and units, colors later.
func sendPayload(startNode : GameNode, endNode : GameNode, unit : Unit):
	var route = pathfind(startNode,endNode)
	
	var roadUnit = RoadUnit.new(unit.currentColor)
	roadUnit.units = unit.units
	roadUnit.route = route
	
	startNode.sendUnit(roadUnit)


func pathfind(startNode : GameNode, endNode : GameNode) -> Array[GameNode]:
	return []

# Gets the road's node1 and node2 and sets themselves as neighbors
func setRoadNodeNeighbors(road : Road):
	var node1 = road.node1
	var node2 = road.node2
	node1.neigbors.append(node2)
	node2.neigbors.append(node1)
