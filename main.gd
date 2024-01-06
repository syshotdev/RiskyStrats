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
func sendPayload(startNode : GameNode, endNode : GameNode, unitAmount  : int):
	var route = pathfind(startNode,endNode)
	
	startNode.sendUnits(route,unitAmount)

# Gets the road's node1 and node2 and sets themselves as neighbors
func setRoadNodeNeighbors(road : Road):
	var node1 = road.node1
	var node2 = road.node2
	node1.neigbors.append(node2)
	node2.neigbors.append(node1)


func pathfind(startNode : GameNode, endNode : GameNode):
	pass
