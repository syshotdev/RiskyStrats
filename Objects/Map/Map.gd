extends Node2D

class_name Map

@export var defaultNodeColor : GameColors.colors

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
	
	for node in nodes:
		node.addUnit(Unit.new(defaultNodeColor, 25))
	
	# TEST FOR PAYLOAD SCRIPT, REMOVE LATER
	if nodes.size() > 0:
		nodes[0].addUnit(Unit.new(GameColors.colors.YELLOW, 300))


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


# Sends payloads to destination with some ifs
func sendPayload(selectedNodes, nodeDestination, unit : Unit):
	for node : GameNode in selectedNodes:
		var color := unit.currentColor
		
		# If this isn't our node, don't send our unit
		if(color != node.currentColor):
			continue
		
		# Moved here because bug
		var maxUnitsCanSend : float = min(node.unitAmounts[color], unit.units) - 1
		
		# If can't send units, don't
		if(maxUnitsCanSend <= 0):
			continue
		
		var newUnit : Unit = Unit.new(color, maxUnitsCanSend)
		newUnit.units = maxUnitsCanSend
		node.unitAmounts[color] -= maxUnitsCanSend
		
		distributer.sendPayload(node, nodeDestination, newUnit)
