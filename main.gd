extends Node2D

var roads
var nodes

func _ready():
	roads = find_child("Roads").get_children()
	nodes = find_child("Nodes").get_children()
	
	# Inits the node's neighbors
	for road in roads:
		setRoadNodeNeighbors(road)
	
	var startNode = nodes[0]
	var endNode = nodes[4]
	
	var distributer = PayloadDistributer.new()
	distributer.sendPayload(startNode,endNode,Unit.new(GameColors.colors.BLUE, 30))


func _process(delta):
	pass

# Gets the road's node1 and node2 and sets themselves as neighbors
func setRoadNodeNeighbors(road : Road):
	var node1 = road.node1
	var node2 = road.node2
	node1.addNeigbor(node2,road)
	node2.addNeigbor(node1,road)
