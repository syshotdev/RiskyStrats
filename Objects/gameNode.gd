extends Node2D

class_name GameNode

signal sendUnitsToRoad()

signal addColorToDisplay(units : Array[Unit])
signal changeNodeColor(color : GameColors.colors)


var neigbors : Array[GameNode] = []

# Key value: color, amount
var unitAmounts : Dictionary = {}

var currentColor : GameColors.colors

# The rate at which one soldier can kill another per unit of time
var killRate : float = 0.1


func _ready():
	var unit : Unit = Unit.new(GameColors.colors.BROWN)
	var unit2 : Unit = Unit.new(GameColors.colors.BLUE)
	
	unit.units = 20
	unit2.units = 19
	
	addUnit(unit)
	addUnit(unit2)


func _process(delta):
	
	unitAmounts = takeDamage(unitAmounts, delta)
	updateColorDisplays(unitAmounts)


# Every tick, it takes damage from other armies until one is dead
# Lanchester's square law
func takeDamage(colorUnits : Dictionary, delta : float) -> Dictionary:
	colorUnits = ridOfEmptySlots(colorUnits)
	
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


func changeCurrentColorToBiggestColor(colorUnits):
	var biggestAmount := 0
	# For every color, check if it's bigger than the current color and set it to the current color if true
	for color in colorUnits:
		var unitAmount = colorUnits[color]
		
		if(unitAmount > biggestAmount):
			currentColor = color
			biggestAmount = unitAmount


# Find out how to pick a road Idk
func sendRoadUnit(road):
	pass

# Translates to unit and adds it to this node
func addRoadUnit(roadUnit : RoadUnit):
	var unit := Unit.new(roadUnit.currentColor)
	unit.units = roadUnit.units
	addUnit(unit)

# Adds it to the dictionary which is just "color, amount"
func addUnit(unit : Unit):
	# Detecting if unit is valid to not have error
	if(unitAmounts.has(unit.currentColor)):
		unitAmounts[unit.currentColor] += unit.units
	else:
		unitAmounts[unit.currentColor] = unit.units
	
	
	unitAmounts = ridOfEmptySlots(unitAmounts)


func ridOfEmptySlots(dictionary : Dictionary) -> Dictionary:
	for key in dictionary.keys():
		if(dictionary[key] <= 0):
			dictionary.erase(key)
	return dictionary

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
