extends Node2D

class_name GameNode


@export var currentColor : GameColors.colors
@export var currentBuildingType : UnitGenerator.buildingType

@export var unitCalculator : UnitCalculator
@export var unitSender : UnitSender
@export var unitGenerator : UnitGenerator

var neighbors : Array[GameNode] = [] # Neighboring nodes
var powerPlants : Dictionary # Neighboring power plants, Key: GameNode, Value: 0


func tick(delta):
	# Just had dejavu lol (6PM Jan 28th 2024)
	# To explain this, a unit is being created with currentColor, and the output of 
	# unitGenerator's calculation of units that should generate.
	unitCalculator.takeDamage(delta)
	unitCalculator.unitAmounts[currentColor] += unitGenerator.calculateUnitAmountGenerated(delta)

# Forward to UnitSender
func addNeighbor(gameNode : GameNode, road : Road):
	neighbors.append(gameNode)
	unitSender.associateRoadWithNode(gameNode, road)

# Will be function to recieve roadUnit color or forward roadUnit to other nodes
func processRoadUnit(roadUnit : RoadUnit):
	var arrived = roadUnit.route.size() == 0
	
	# If it has arrived, add it. Otherwise forward to next path.
	if(arrived):
		unitCalculator.addRoadUnit(roadUnit)
	else:
		unitSender.sendRoadUnit(roadUnit)

# To fix stuff
func addUnit(unit : Unit):
	unitCalculator.addUnit(unit)

# Takes all node neighbors and finds if they're powerplant
func recalculateInfluences():
	var numPowerPlants : int = 0
	var numArtillery : int = 0
	
	for neighbor in neighbors:
		var neighborBuildingType = neighbor.unitGenerator.currentBuildingType
		
		# If neighbor == reactor and our color, add 0.5x to our generation speed
		if(neighborBuildingType == unitGenerator.buildingType.REACTOR):
			if(neighbor.currentColor == currentColor):
				numPowerPlants += 1
		
		# If neighbor == artillery and different color (Enemy color), add one to artillery
		elif(neighborBuildingType == unitGenerator.buildingType.ARTILLERY):
			if(neighbor.currentColor != currentColor):
				numArtillery += 1
	
	unitGenerator.setEffectiveness(numPowerPlants)

# When changed to powerplant
func changedToPowerPlant():
	for node in neighbors:
		node.recalculateInfluences()

# When captured
func selfCaptured():
	for node in neighbors:
		node.recalculateInfluences()

# Basically when color changed (captured by another color)
func updateCurrentColor(color : GameColors.colors):
	currentColor = color
	selfCaptured()


func onUnitGeneratorReady():
	unitGenerator.currentBuildingType = currentBuildingType
