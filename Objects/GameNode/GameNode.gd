@tool
extends Node2D
class_name GameNode

# Mapping variables
@export var color : GameColors.colors
@export var units : int
@export var type : GameTypes.buildingType

@onready var visibilityNotifier := $VisibleOnScreenNotifier2D
@onready var colorManager := $ColorManager
@onready var circle := $ColorManager/WhiteCircle
@onready var sprite := $ColorManager/Sprite2D

var neighbors : Array[GameNode] = [] # Neighboring nodes
var roads : Dictionary = {} # Key node, value road. Which roads to get to a neighbor?

const killRate : float = 0.02 # The rate at which one soldier can kill another per unit of time
const generateRate : float = 20.0 # Rate default node generates per second
var generateEffectiveness : float = 1.0 # Multiplier for genRate
var defenseEffectiveness : float = 1.0 # Forts -> up; Artilleries -> down.


var unitAmounts : Dictionary = {} # Key color, value amount

func _ready() -> void:
	visibilityNotifier.screen_entered.connect(func() -> void: add_to_group(GameTypes.GROUP_ONSCREEN))
	visibilityNotifier.screen_exited.connect(func() -> void: remove_from_group(GameTypes.GROUP_ONSCREEN))
	
	addUnit(Unit.new(color, 25))
	
	updateColorDisplay(unitAmounts)
	updateBuildingType(type)


func tick(delta):
	takeDamage(delta)
	unitAmounts[color] += calculateUnitAmountGenerated(delta)


# ---------- UNIT BATTLING ----------

# Every tick, it takes damage from other armies until one is dead
# Lanchester's square law
func takeDamage(delta : float) -> void:
	updateColorDisplay(unitAmounts)
	
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
	
	match type:
		GameTypes.none: output = 0
		GameTypes.capitol: output = generateRate * generateEffectiveness * delta * 2
		GameTypes.factory: output = generateRate * generateEffectiveness * delta
	
	return output


# ---------- INFLUENCES ----------

# Changes the building type to specified, and subtracts cost, and returns if success or not
func buyBuildingType(type : GameTypes.buildingType) -> bool:
	var cost := GameTypes.getCostFromType(type)
	# If not enough units, return
	if(unitAmounts[color] <= cost):
		return false
	unitAmounts[color] -= cost
	updateBuildingType(type)
	return true

# Takes all node neighbors and finds if they're powerplant
func recalculateInfluences():
	var numPowerPlants : int = 0
	var numArtillery : int = 0
	
	for neighbor : GameNode in neighbors:
		match neighbor.type:
			GameTypes.reactor:
				if neighbor.color == self.color:
					numPowerPlants += 1
			GameTypes.artillery:
				if neighbor.color != self.color:
					numArtillery += 1
	
	generateEffectiveness = pow(1.5, numPowerPlants)
	defenseEffectiveness = (1 + (1 if isFort() else 0)) / numArtillery


func isFort() -> bool:
	return self.type == GameTypes.fort

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


# ---------- DISPLAY -----------
func updateColorDisplay(colorUnits : Dictionary):
	colorManager.updateColorDisplay(colorUnits)

func updateBuildingType(type : GameTypes.buildingType):
	self.type = type
	colorManager.updateBuildingDisplay(type)
	
	# If we're a powerplant, send out a signal to update other nodes
	if(type == GameTypes.reactor):
		neighborsRecalculateInfluences()

# Basically when color changed (captured by another color)
func updateColor(color : GameColors.colors):
	self.color = color
	selfCaptured()

# Reactors and arty sort of things
func selfCaptured():
	for node in neighbors:
		node.recalculateInfluences()

func displaySelected(b : bool):
	circle.visible = b

func getBoundingRect() -> Rect2:
	var r : Rect2 = sprite.get_rect()
	r.position = global_position + r.position
	return r


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
