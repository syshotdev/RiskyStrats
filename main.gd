extends Node2D


@export var selectionArea : SelectionArea

@onready var distributer : PayloadDistributer = PayloadDistributer.new()

var roads
var nodes


func _ready():
	roads = find_child("Roads").get_children()
	nodes = find_child("Nodes").get_children()
	
	# Inits the node's neighbors
	for road in roads:
		setRoadNodeNeighbors(road)


func _process(delta):
	for road in roads:
		road.moveAllRoadUnits(delta)
	for node in nodes:
		node.tick(delta)
	
	$SelectionArea.tick(delta)
	sendSelectedPayloads(selectionArea.selectedNodes, 10)


func sendSelectedPayloads(selectedNodes : Array[GameNode], amount : int):
	for node in selectedNodes:
		distributer.sendPayload(node,nodes[2],Unit.new(GameColors.colors.BLUE, amount))

# Gets the road's node1 and node2 and sets themselves as neighbors
func setRoadNodeNeighbors(road : Road):
	var node1 = road.node1
	var node2 = road.node2
	node1.addNeigbor(node2,road)
	node2.addNeigbor(node1,road)
