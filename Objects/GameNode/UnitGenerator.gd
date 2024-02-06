extends Node

class_name UnitGenerator

signal buildingTypeChanged(type : GameTypes.buildingType)

@export var parent : GameNode

# Rate default node generates per second
const genRate : float = 5.0
var effectiveness : float = 1 # Multiplier for genRate

# This current building type
var currentBuildingType : GameTypes.buildingType : set = changeBuildingType

# Calculates the amount of units generated with factors like genRate and effectiveness
func calculateUnitAmountGenerated(delta : float) -> float:
	var output : float = 0
	
	if(currentBuildingType == GameTypes.none):
		output = 0;
	elif(currentBuildingType == GameTypes.capitol):
		# *2 because gens double the normal amount
		output += genRate * effectiveness * 2 * delta
	elif(currentBuildingType == GameTypes.factory):
		output += genRate * effectiveness * delta
	
	return output

# Calculates the effectiveness
func setEffectiveness(numPowerPlants : int):
	effectiveness = 1 + (0.5 * numPowerPlants)


func changeBuildingType(newType : GameTypes.buildingType):
	currentBuildingType = newType
	buildingTypeChanged.emit(newType)
