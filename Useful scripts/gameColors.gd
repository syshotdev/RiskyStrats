extends Node

class_name GameColors

enum colors{
	GAIA,
	GREEN,
	PURPLE,
	BLUE,
	LIGHT_BLUE,
	RED,
	YELLOW,
	ORANGE,
	BROWN
}

static var gaia : Color = Color("b9b9b9")
static var green : Color = Color("06fc73")
static var purple : Color = Color("a543f1")
static var blue : Color = Color("448fff")
static var lightBlue : Color = Color("39feff")
static var red : Color = Color("fb1400")
static var yellow : Color = Color("f5ce03")
static var orange : Color = Color("ff8c2a")
static var brown : Color = Color("976108")
static var selectionColor : Color = Color(1,1,1,0.1)

static func getColorFromEnum(color : colors) -> Color:
	if(color == colors.GAIA):
		return gaia
	elif(color == colors.GREEN):
		return green
	elif(color == colors.PURPLE):
		return purple
	elif(color == colors.RED):
		return red
	elif(color == colors.BLUE):
		return blue
	elif(color == colors.GREEN):
		return green
	elif(color == colors.LIGHT_BLUE):
		return lightBlue
	elif(color == colors.YELLOW):
		return yellow
	elif(color == colors.ORANGE):
		return orange
	elif(color == colors.BROWN):
		return brown
	return Color(0,0,0)
