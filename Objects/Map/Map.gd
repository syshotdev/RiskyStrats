extends Node2D

class_name Map

@onready var distributer : PayloadDistributer = PayloadDistributer.new()

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
		setRoadNodeNeighbors(road)


# Gets the road's node1 and node2 and sets themselves as neighbors
func setRoadNodeNeighbors(road : Road):
	var node1 = road.node1
	var node2 = road.node2
	node1.addNeigbor(node2,road)
	node2.addNeigbor(node1,road)


# Copies a map that has been created
func loadMap(map : Map):
	nodes = map.nodes.duplicate()
	roads = map.roads.duplicate()


# Sends a payload
func sendPayload(selectedNodes, nodeDestination, unit : Unit):
	for node in selectedNodes:
		# Add some checking to see if the nodes have enough "unit" to send
		
		distributer.sendPayload(node, nodeDestination, unit)
