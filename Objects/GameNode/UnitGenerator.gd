extends Node

class_name UnitGenerator

signal changedToPowerPlant()

enum buildingType{
	NONE,
	CAPITOL,
	FACTORY,
	FORT,
	REACTOR,
	ARTILLERY,
}

# Rate default node generates per second
const genRate : float = 5.0

@export var parent : GameNode

var effectiveness : float = 1 # Multiplier for genRate

# This current building type
var currentBuildingType : buildingType : set = changeBuildingType


func calculateUnitAmountGenerated(delta : float) -> float:
	var output : float = 0
	
	if(currentBuildingType == buildingType.NONE):
		output = 0
	elif(currentBuildingType == buildingType.CAPITOL):
		# *2 because gens double the normal amount
		output += genRate * 2 * delta
	elif(currentBuildingType == buildingType.FACTORY):
		output += genRate * delta
	
	return output

# If self is artillery or power plant, then add buff or "add powerplant" to the node given.
func checkIfCanAddBuffs(node : GameNode):
	if currentBuildingType != buildingType.REACTOR:
		return
	
	# If node is current color, give buff.
	if node.currentColor == parent.currentColor:
		node.addPowerPlant(parent)
	else:
		node.removePowerPlant(parent)


func calculateEffectiveness():
	var numPowerPlants : int = parent.powerPlants.size()
	effectiveness = 1 + (0.5 * numPowerPlants)


func changeBuildingType(newType : buildingType):
	# Code for switching sprites based on type
	# Maybe also updating neighbor nodes that they have powerplant next to them
	currentBuildingType = newType
	
	# If we're a powerplant, send out a signal to update other nodes
	if(currentBuildingType == buildingType.REACTOR):
		changedToPowerPlant.emit()
