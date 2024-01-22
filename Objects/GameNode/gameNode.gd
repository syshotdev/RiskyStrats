extends Node2D

class_name GameNode

signal addColorToDisplay(units : Array[Unit])
signal changeNodeColor(color : GameColors.colors)


@export var currentColor : GameColors.colors

var neigbors : Array[GameNode] = []
var neigborRoads : Dictionary = {} # Key node, value road
var unitAmounts : Dictionary = {} # Key color, value amount

# The rate at which one soldier can kill another per unit of time
var killRate : float = 0.02


func tick(delta):
	unitAmounts = takeDamage(unitAmounts, delta)
	updateColorDisplays(unitAmounts)


# Adds a neighbor and associates that neighbor with the road.
func addNeigbor(neigbor : GameNode, road : Road):
	neigbors.append(neigbor)
	# To get the road from the neigbor
	neigborRoads[neigbor] = road

# Will be function to recieve roadUnit color or forward roadUnit to other nodes
func processRoadUnit(roadUnit : RoadUnit):
	var arrived = roadUnit.route.size() == 0
	
	# If it has arrived, add it. Otherwise forward to next path.
	if(arrived):
		addRoadUnit(roadUnit)
	else:
		sendRoadUnit(roadUnit)

# Sends a unit to the next road based on the route
func sendRoadUnit(roadUnit : RoadUnit):
	var road = getRoadToNode(roadUnit.route[0])
	
	# Get rid of first destination to mark that we've been to this node
	roadUnit.route.remove_at(0)
	# If road.node1 == self, that means we are node1. We should then send to node2.
	roadUnit.toSecondNode = road.node1 == self
	
	# Forward unit, don't queue_free() it
	road.addUnitToRoad(roadUnit)


# From this node to the node specified, which road is it?
func getRoadToNode(node : GameNode) -> Road:
	return neigborRoads[node]

# Translates to unit and adds it to this node
func addRoadUnit(roadUnit : RoadUnit):
	var unit := Unit.new(roadUnit.currentColor, roadUnit.units)
	addUnit(unit)
	roadUnit.queue_free()

# Adds it to the dictionary which is just "color, amount"
func addUnit(unit : Unit):
	# Detecting if unit is valid to not have error
	if(unitAmounts.has(unit.currentColor)):
		unitAmounts[unit.currentColor] += unit.units
	else:
		unitAmounts[unit.currentColor] = unit.units
	
	unitAmounts = ridOfEmptySlots(unitAmounts)

# Every tick, it takes damage from other armies until one is dead
# Lanchester's square law
func takeDamage(colorUnits : Dictionary, delta : float) -> Dictionary:
	colorUnits = ridOfEmptySlots(colorUnits)
	
	# If colorUnits dict empty, return to not crash
	if (colorUnits.size() == 0):
		return colorUnits
	
	# This if for when your node has been taken over, 
	# and now the current color occupying it is not current color
	if(colorUnits.size() == 1):
		currentColor = colorUnits.keys()[0]
		return colorUnits
	
	# If the current color doesn't exist, turn it to the biggest color.
	if(!colorUnits.has(currentColor)):
		changeCurrentColorToBiggestColor(colorUnits)
	
	var enemyUnits := getEnemyUnits(colorUnits)
	
	# Current amount of our own color in this node
	var currentUnits : float = colorUnits[currentColor]
	
	# Gets the total amount of units attacking this node
	var totalEnemyUnits : float = 0.0
	
	for unit in enemyUnits:
		totalEnemyUnits += unit.units
	
	# Square part of lanchester's law
	# The 4x part or square part
	var currentEffectiveness : float = pow(currentUnits, 2)/pow(totalEnemyUnits, 2)
	var enemyEffectiveness : float = pow(totalEnemyUnits, 2)/pow(currentUnits, 2)
	
	# Losses of armies
	var currentLoss = killRate * enemyEffectiveness * totalEnemyUnits * delta
	var enemyLoss = killRate * currentEffectiveness * currentUnits * delta
	
	# Apply changes
	colorUnits[currentColor] = (currentUnits - currentLoss)
	
	for unit in enemyUnits:
		unit.units -= enemyLoss
		
		# Apply to the colorunits dictionary
		colorUnits[unit.currentColor] = unit.units
	
	return colorUnits

# Easy
func getEnemyUnits(colorUnits : Dictionary) -> Array[Unit]:
	var units : Array[Unit] = []
	
	for color in colorUnits.keys():
		if color == currentColor:
			continue
		
		var unit = Unit.new(color)
		unit.units = colorUnits[color]
		
		units.append(unit)
	
	return units


func ridOfEmptySlots(dictionary : Dictionary) -> Dictionary:
	for key in dictionary.keys():
		if(dictionary[key] <= 0):
			dictionary.erase(key)
	return dictionary

# When selection updated, turn on white circle to show selection
func onSelected(selected):
	# While circle script here
	pass


func changeCurrentColorToBiggestColor(colorUnits):
	var biggestAmount := 0
	# For every color, check if it's bigger than the current color and set it to the current color if true
	for color in colorUnits:
		var unitAmount = colorUnits[color]
		
		if(unitAmount > biggestAmount):
			currentColor = color
			biggestAmount = unitAmount

# Updates the color of the colorRect and the label displays
func updateColorDisplays(colorUnits : Dictionary):
	var units : Array[Unit] = []
	for color in colorUnits:
		var unit = Unit.new(color)
		
		# Get amount of units
		unit.units = colorUnits[color]
		
		# Add to units array
		units.append(unit)
	
	# Send signal to update labels
	addColorToDisplay.emit(units)
	
	# Sends a signal to update color rect
	changeNodeColor.emit(currentColor)
