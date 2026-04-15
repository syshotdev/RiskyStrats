extends Node2D

class_name GameNode

signal updateLabels
signal addLabel
signal colorChanged

enum Type{
	NOTHING,
	FACTORY,
	POWER_PLANT,
	FORT,
	ARTILLERY,
	CAPITOL
}

enum Team{
	GAIA,
	GREEN,
	PURPLE,
	BLUE,
	LIGHT_BLUE,
	RED,
	YELLOW,
	ORANGE,
	BROWN,
}

@export var currentType : Type
@export var currentTeam : Team

@export var labelComponent : VBoxContainer

@export var gaiaColor : Color = Color("b9b9b9")
@export var greenColor : Color = Color("06fc73")
@export var purpleColor : Color = Color("a543f1")
@export var blueColor : Color = Color("448fff")
@export var lightBlueColor : Color = Color("39feff")
@export var redColor : Color = Color("fb1400")
@export var yellowColor : Color = Color("f5ce03")
@export var orangeColor : Color = Color("ff8c2a")
@export var brownColor : Color = Color("976108")

var colorDictionary : Dictionary = {
	Team.GAIA : gaiaColor,
	Team.GREEN : greenColor,
	Team.PURPLE : purpleColor,
	Team.BLUE : blueColor,
	Team.LIGHT_BLUE : lightBlueColor,
	Team.RED : redColor,
	Team.YELLOW : yellowColor,
	Team.ORANGE : orangeColor,
	Team.BROWN : brownColor,
}



# All of the teams in this node
var allTeamsInNode : Dictionary

# The rate at which one soldier can kill another per unit of time
var killRate : float = 0.1

const defaultUnits : int = 501
var currentUnits : int = defaultUnits


# Create node
func _init(type : Type = Type.NOTHING, team : Team = Team.PURPLE):
	currentType = type
	currentTeam = team
	
	# Create Gaia
	addUnitsToTeam(team, currentUnits)
	addUnitsToTeam(Team.BROWN, 10)


func colorRectReady():
	setColor(currentTeam)


func labelContainerReady():
	checkAndRemoveDeadTeams()


func setColor(color : Team):
	colorChanged.emit(colorDictionary[color])


func makeDummyEnemy():
	addUnitsToTeam(Team.BLUE, 25)


func checkAndRemoveDeadTeams():
	for team in allTeamsInNode:
		if(allTeamsInNode[team] <= 0):
			allTeamsInNode.erase(team)
		else:
			labelComponent.makeNewLabel(team, colorDictionary[team])
	
	
	checkAndRemoveLabels()


# Messy code, will refactor later
func checkAndRemoveLabels():
	labelComponent.checkLabels(allTeamsInNode)
	labelComponent.updateLabels()


# Add the amount of soldiers to this node from color
func addUnitsToTeam(color : Team, amount : int):
	if(allTeamsInNode.has(color)):
		allTeamsInNode[color] += amount
	else:
		allTeamsInNode[color] = amount


# Every tick, it takes damage from other armies until one is dead
# Lanchester's square law
func takeDamage():
	var activeTeams = getNodeActiveTeams()
	
	# Check if everyone died
	if(activeTeams.size() == 0): return
	
	# Check if last one ours, otherwise
	# change active team to the last standing
	if(activeTeams.size() == 1):
		
		# Check if ours
		if(activeTeams[0] == currentTeam): return
		else: 
			currentTeam = activeTeams[0]
			return
	
	# Every team except current team
	var enemyTeams : Array[Team] = []
	for index in range(activeTeams.size()):
		if(activeTeams[index] != currentTeam):
			enemyTeams.append(activeTeams[index])
	
	
	var totalEnemyUnits : int = 0
	
	# Get total amount of units attacking this thing
	for team in enemyTeams:
		totalEnemyUnits += allTeamsInNode[team]
	
	# Square part of lanchester's law
	# The 4x part or square part
	var currentEffectiveness : float = pow(currentUnits, 2)/pow(totalEnemyUnits, 2)
	var enemyEffectiveness : float = pow(totalEnemyUnits, 2)/pow(currentUnits, 2)
	
	# Losses of armies
	var currentLoss = floor(killRate * enemyEffectiveness * totalEnemyUnits)
	var enemyLoss = floor(killRate * currentEffectiveness * currentUnits)
	
	# Apply changes
	currentUnits = (currentUnits - currentLoss)
	currentUnits = max(currentUnits, 0)
	
	for team in enemyTeams:
		allTeamsInNode[team] -= enemyLoss
		allTeamsInNode[team] = max(allTeamsInNode[team], 0)
	
	checkAndRemoveDeadTeams()


# Returns an array of teams currently with 1 or more units in this node
func getNodeActiveTeams() -> Array[Team]:
	
	var currentActiveTeams : Array[Team] = [Team.GAIA]
	
	# For every team in the teams list, Check the units.
	# If the units is more than zero, then it's not dead and is active
	for team in allTeamsInNode:
		var units = allTeamsInNode[team]
		
		if(units > 0):
			currentActiveTeams.append(team)
	
	return currentActiveTeams
