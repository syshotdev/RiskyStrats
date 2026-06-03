extends Node

class_name GameTypes

enum buildingType{
	NONE,
	CAPITOL,
	FACTORY,
	FORT,
	REACTOR,
	ARTILLERY,
}

# All of the building costs (for purposes)
static var buildingCosts : Dictionary = {
	GameTypes.buildingType.FACTORY : 500,
	GameTypes.buildingType.REACTOR : 2500,
	GameTypes.buildingType.FORT : 500,
	GameTypes.buildingType.ARTILLERY : 5000,
}

static func getCostFromType(type : buildingType) -> int:
	return buildingCosts[type]

# Easier access to building type
const none = buildingType.NONE
const capitol = buildingType.CAPITOL
const factory = buildingType.FACTORY
const fort = buildingType.FORT
const reactor = buildingType.REACTOR
const artillery = buildingType.ARTILLERY


# Paths to all of the sprites (used in GameNode.$Control.$Sprite2D)
static var _nonePath := "res://Sprites/Node.png"
static var _capitolPath := "res://Sprites/Capitol.png"
static var _factoryPath := "res://Sprites/Factory.png"
static var _fortPath := "res://Sprites/Fort.png"
static var _reactorPath := "res://Sprites/Powerplant.png"
static var _artilleryPath := "res://Sprites/Artillery.png"


# Returns the path to the sprite which is associated
static func getSpriteFromEnum(type : buildingType) -> NodePath:
	if(type == none):
		return _nonePath
	if(type == capitol):
		return _capitolPath
	if(type == factory):
		return _factoryPath
	if(type == fort):
		return _fortPath
	if(type == reactor):
		return _reactorPath
	if(type == artillery):
		return _artilleryPath
	
	# Last resort if no image is found
	return _nonePath

# Groups
const GROUP_ONSCREEN := "onscreen_nodes"
