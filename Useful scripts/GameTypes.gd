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

# Easier access to building type
const none = buildingType.NONE
const capitol = buildingType.CAPITOL
const factory = buildingType.FACTORY
const fort = buildingType.FORT
const reactor = buildingType.REACTOR
const artillery = buildingType.ARTILLERY


# Paths to all of the sprites (used in GameNode.$Control.$Sprite2D)
static var nonePath := "res://Sprites/Node.png"
static var capitolPath := "res://Sprites/Capitol.png"
static var factoryPath := "res://Sprites/Factory.png"
static var fortPath := "res://Sprites/Fort.png"
static var reactorPath := "res://Sprites/Powerplant.png"
static var artilleryPath := "res://Sprites/Artillery.png"


# Returns the path to the sprite which is associated
static func getSpriteFromEnum(type : buildingType) -> NodePath:
	if(type == none):
		return nonePath
	if(type == capitol):
		return capitolPath
	if(type == factory):
		return factoryPath
	if(type == fort):
		return fortPath
	if(type == reactor):
		return reactorPath
	if(type == artillery):
		return artilleryPath
	
	# Last resort if no image is found
	return nonePath
