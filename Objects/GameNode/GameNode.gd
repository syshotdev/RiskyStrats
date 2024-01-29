extends Node2D

class_name GameNode


@export var currentColor : GameColors.colors
@export var currentBuildingType : UnitGenerator.buildingType

@export var unitCalculator : UnitCalculator
@export var unitSender : UnitSender
@export var unitGenerator : UnitGenerator

# Neighboring nodes:
var neigbors : Array[GameNode] = []


func tick(delta):
	# Just had dejavu lol (6PM Jan 28th 2024)
	# To explain this, a unit is being created with currentColor, and the output of 
	# unitGenerator's calculation of units that should generate.
	var unit : Unit = Unit.new(currentColor, unitGenerator.calculateUnitAmountGenerated(delta))
	unitCalculator.takeDamage(delta)

# Forward to UnitSender
func addNeighbor(gameNode : GameNode, road : Road):
	neigbors.append(gameNode)
	unitSender.associateRoadWithNode(gameNode, road)

# Will be function to recieve roadUnit color or forward roadUnit to other nodes
func processRoadUnit(roadUnit : RoadUnit):
	var arrived = roadUnit.route.size() == 0
	
	# If it has arrived, add it. Otherwise forward to next path.
	if(arrived):
		unitCalculator.addRoadUnit(roadUnit)
	else:
		unitSender.sendRoadUnit(roadUnit)


func updateCurrentColor(color : GameColors.colors):
	currentColor = color


func onUnitGeneratorReady():
	unitGenerator.currentBuildingType = currentBuildingType
