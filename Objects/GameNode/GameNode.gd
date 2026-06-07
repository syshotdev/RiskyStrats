extends Node2D
class_name GameNode

signal updateColorDisplay(units : Array[Unit])
signal buildingTypeChanged(type : GameTypes.buildingType)

# Mapping variables
@export var color : GameColors.colors
@export var type : GameTypes.buildingType

@onready var visibilityNotifier := $VisibleOnScreenNotifier2D
@onready var visualSelection := $ColorManager/WhiteCircle
@onready var visualRect := $ColorManager/Sprite2D

var neighbors : Array[GameNode] = [] # Neighboring nodes
var roads : Dictionary = {} # Key node, value road. Which roads to get to a neighbor?

const genRate : float = 5.0 # Rate default node generates per second
var effectiveness : float = 1.0 # Multiplier for genRate
var killRate : float = 0.02 # The rate at which one soldier can kill another per unit of time

var unitAmounts : Dictionary = {} # Key color, value amount

func _ready() -> void:
	visibilityNotifier.screen_entered.connect(func() -> void: add_to_group(GameTypes.GROUP_ONSCREEN))
	visibilityNotifier.screen_exited.connect(func() -> void: remove_from_group(GameTypes.GROUP_ONSCREEN))
	
	updateColorDisplays(unitAmounts)
	changeBuildingType(type)


func tick(delta):
	takeDamage(delta)
	unitAmounts[color] += calculateUnitAmountGenerated(delta)


# ---------- UNIT BATTLING ----------

# Every tick, it takes damage from other armies until one is dead
# Lanchester's square law
func takeDamage(delta : float) -> void:
	updateColorDisplays(unitAmounts)
	
	unitAmounts = ridOfEmptySlots(unitAmounts)
	
	# If unitAmounts dict empty, return to not crash
	if (unitAmounts.size() == 0):
		return
	
	# This if for when your node has been taken over, 
	# and now the current color occupying it is not current color
	if(unitAmounts.size() == 1):
		color = unitAmounts.keys()[0]
		return
	
	# If the current color doesn't exist, turn it to the biggest color.
	if(!unitAmounts.has(color)):
		changeColorToBiggestColor(unitAmounts)
	
	var enemyUnits := getEnemyUnits(unitAmounts)
	# Current amount of our own color in this node
	var currentUnits : float = unitAmounts[color]
	
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
	unitAmounts[color] = (currentUnits - currentLoss)
	
	for unit in enemyUnits:
		unit.units -= enemyLoss
		
		# Apply to the unitAmounts dictionary
		unitAmounts[unit.color] = unit.units


# ---------- UNIT GENERATION ----------

# Calculates the amount of units generated with factors like genRate and effectiveness
func calculateUnitAmountGenerated(delta : float) -> float:
	var output : float = 0
	
	if(type == GameTypes.none):
		output = 0;
	elif(type == GameTypes.capitol):
		# *2 because gens double the normal amount
		output += genRate * effectiveness * 2 * delta
	elif(type == GameTypes.factory):
		output += genRate * effectiveness * delta
	
	return output


# ---------- INFLUENCES ----------

# Changes the building type to specified, and subtracts cost, and returns if success or not
func buyBuildingType(type : GameTypes.buildingType) -> bool:
	var cost := GameTypes.getCostFromType(type)
	# If not enough units, return
	if(unitAmounts[color] <= cost):
		return false
	unitAmounts[color] -= cost
	changeBuildingType(type)
	return true

func changeBuildingType(type : GameTypes.buildingType):
	type = type
	buildingTypeChanged.emit(type)
	
	# If we're a powerplant, send out a signal to update other nodes
	if(type == GameTypes.reactor):
		neighborsRecalculateInfluences()

# Takes all node neighbors and finds if they're powerplant
func recalculateInfluences():
	var numPowerPlants : int = 0
	var numArtillery : int = 0
	
	for neighbor : GameNode in neighbors:
		# If neighbor == reactor and our color, add 0.5x to our generation speed
		if(neighbor.type == GameTypes.reactor):
			if(neighbor.color == color):
				numPowerPlants += 1
		
		# If neighbor == artillery and different color (Enemy color), add one to artillery
		elif(neighbor.type == GameTypes.artillery):
			if(neighbor.color != color):
				numArtillery += 1
	
	effectiveness = 1 * (0.5 * numPowerPlants)

# For all neighbors, recalculate the influences
func neighborsRecalculateInfluences():
	for neighbor in neighbors:
		neighbor.recalculateInfluences()


# ---------- NODE ROADS AND NEIGHBORS ----------

# Forward to UnitSender
func addNeighbor(neighbor : GameNode, road : Road):
	neighbors.append(neighbor)
	roads[neighbor] = road


func getRoadToNeighbor(neighbor : GameNode) -> Road:
	return roads[neighbor]


# ---------- ROAD UNITS ----------

# Will be function to recieve roadUnit color or forward roadUnit to other nodes
func processRoadUnit(roadUnit : RoadUnit):
	var arrived = roadUnit.route.size() == 0
	
	if(arrived):
		addRoadUnit(roadUnit)
	else:
		sendRoadUnit(roadUnit)

# Translates to unit and adds it to unit amounts in UnitCalculator
func addRoadUnit(roadUnit : RoadUnit):
	var unit := Unit.new(roadUnit.color, roadUnit.units)
	addUnit(unit)
	roadUnit.queue_free()

func addUnit(unit : Unit):
	# If unitAmounts has the color, add. If it doesn't, make new entry.
	if(unitAmounts.has(unit.color)):
		unitAmounts[unit.color] = unit.units + unitAmounts[unit.color]
	else:
		unitAmounts[unit.color] = unit.units
	unit.queue_free()

# Sends a unit to the next road based on the route
func sendRoadUnit(roadUnit : RoadUnit):
	var road = getRoadToNeighbor(roadUnit.route[0])
	
	# Get rid of first destination to mark that we've been to this node
	roadUnit.route.remove_at(0)
	# If road.node1 == self, that means we are node1. We should then send to node2.
	roadUnit.toSecondNode = road.node1 == self
	
	# Forward unit, don't queue_free() it
	road.addUnitToRoad(roadUnit)


# ---------- DISPLAY ----------

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
	updateColorDisplay.emit(units)

# Basically when color changed (captured by another color)
func updateColor(color : GameColors.colors):
	self.color = color
	selfCaptured()

# When captured
func selfCaptured():
	for node in neighbors:
		node.recalculateInfluences()

func displaySelected(v : bool):
	visualSelection.visible = v

func getBoundingRect() -> Rect2:
	var r : Rect2 = visualRect.get_rect()
	var gp = global_position
	$ColorManager/WhiteCircle.global_position = gp
	$ColorManager/WhiteCircle.radius = r.size.x
	$ColorManager/WhiteCircle.queue_redraw()
	return Rect2(gp.x, gp.y, r.size.x, r.size.y)


# ---------- UTILITIES ----------

# Changes current color variable to biggest color.
func changeColorToBiggestColor(colorUnits):
	var biggestAmount := 0
	# For every color, check if it's bigger than the current color and set it to the current color if true
	for color in colorUnits.keys():
		var unitAmount = colorUnits[color]
		
		if(unitAmount > biggestAmount):
			self.color = color
			biggestAmount = unitAmount

# Get the enemy units from a dictionary
func getEnemyUnits(colorUnits : Dictionary) -> Array[Unit]:
	var units : Array[Unit] = []
	
	for color in colorUnits.keys():
		if color == self.color:
			continue
		
		var unit = Unit.new(color)
		unit.units = colorUnits[color]
		
		units.append(unit)
	
	return units

# Does what it says
func ridOfEmptySlots(dictionary : Dictionary) -> Dictionary:
	for key in dictionary.keys():
		if(dictionary[key] <= 0):
			dictionary.erase(key)
	return dictionary
