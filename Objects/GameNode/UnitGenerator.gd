extends Node

class_name UnitGenerator

signal updateBuildingType(newBuildingType : buildingType)

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

# This current building type
var currentBuildingType : buildingType : set = changeBuildingType


func calculateUnitAmountGenerated(delta : float) -> float:
	var output : float
	
	if(currentBuildingType == buildingType.NONE):
		output
	elif(currentBuildingType == buildingType.CAPITOL):
		# *2 because gens double the normal amount
		output += genRate * 2 * delta
	elif(currentBuildingType == buildingType.FACTORY):
		output += genRate * delta
	
	return output


func changeBuildingType(newType : buildingType):
	#buildingType = newType
	# Code for switching sprites based on type
	# Maybe also updating neighbor nodes that they have powerplant next to them
	updateBuildingType.emit(newType)
	currentBuildingType = newType
