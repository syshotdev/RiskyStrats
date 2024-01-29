extends Node
class_name UnitCalculator
# This exists to take less of the load off of the GameNode parent.
# Calculates unit amounts, and keeps track of units

signal updateColor(color : GameColors.colors)

# For updating display stuff
signal addColorToDisplay(units : Array[Unit])
signal changeNodeColor(color : GameColors.colors)


var currentColor : GameColors.colors : set = updateGameNodeColor
var unitAmounts : Dictionary = {} # Key color, value amount

# The rate at which one soldier can kill another per unit of time
var killRate : float = 0.02


# Translates to unit and adds it to unit amounts in UnitCalculator
func addRoadUnit(roadUnit : RoadUnit):
	var unit := Unit.new(roadUnit.currentColor, roadUnit.units)
	addUnit(unit)
	roadUnit.queue_free()


func addUnit(unit : Unit):
	# If unitAmounts has the color, add. If it doesn't, make new entry.
	if(unitAmounts.has(unit.currentColor)):
		unitAmounts[unit.currentColor] = unit.units + unitAmounts[unit.currentColor]
	else:
		unitAmounts[unit.currentColor] = unit.units


# Every tick, it takes damage from other armies until one is dead
# Lanchester's square law
func takeDamage(delta : float) -> void:
	unitAmounts = ridOfEmptySlots(unitAmounts)
	
	# If unitAmounts dict empty, return to not crash
	if (unitAmounts.size() == 0):
		return
	
	# This if for when your node has been taken over, 
	# and now the current color occupying it is not current color
	if(unitAmounts.size() == 1):
		currentColor = unitAmounts.keys()[0]
		return
	
	# If the current color doesn't exist, turn it to the biggest color.
	if(!unitAmounts.has(currentColor)):
		changeCurrentColorToBiggestColor(unitAmounts)
	
	var enemyUnits := getEnemyUnits(unitAmounts)
	# Current amount of our own color in this node
	var currentUnits : float = unitAmounts[currentColor]
	
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
	unitAmounts[currentColor] = (currentUnits - currentLoss)
	
	for unit in enemyUnits:
		unit.units -= enemyLoss
		
		# Apply to the unitAmounts dictionary
		unitAmounts[unit.currentColor] = unit.units

# Easy
func getEnemyUnits(unitAmounts : Dictionary) -> Array[Unit]:
	var units : Array[Unit] = []
	
	for color in unitAmounts.keys():
		if color == currentColor:
			continue
		
		var unit = Unit.new(color)
		unit.units = unitAmounts[color]
		
		units.append(unit)
	
	return units

# Sends a signal to update "currentColor" in parent node, when this "currentColor" is set.
func updateGameNodeColor(color : GameColors.colors):
	updateColor.emit(color)

# Changes current color variable to biggest color.
func changeCurrentColorToBiggestColor(unitAmounts):
	var biggestAmount := 0
	# For every color, check if it's bigger than the current color and set it to the current color if true
	for color in unitAmounts:
		var unitAmount = unitAmounts[color]
		
		if(unitAmount > biggestAmount):
			currentColor = color
			biggestAmount = unitAmount

# Does what it says
func ridOfEmptySlots(dictionary : Dictionary) -> Dictionary:
	for key in dictionary.keys():
		if(dictionary[key] <= 0):
			dictionary.erase(key)
	return dictionary

# Updates the color of the colorRect and the label displays
func updateColorDisplays(unitAmounts : Dictionary):
	var units : Array[Unit] = []
	for color in unitAmounts:
		var unit = Unit.new(color)
		
		# Get amount of units
		unit.units = unitAmounts[color]
		
		# Add to units array
		units.append(unit)
	
	# Send signal to update labels
	addColorToDisplay.emit(units)
	# Sends a signal to update color rect
	changeNodeColor.emit(currentColor)
