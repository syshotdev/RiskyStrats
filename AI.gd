extends Node2D

signal orderSendPayload(
	color : GameColors.colors, 
	nodes : Array[GameNode], 
	target : GameNode, 
	amount : int
)
signal orderBuyBuilding(
	color : GameColors.colors, 
	target : GameNode, 
	type : GameTypes.buildingType
)

@export var color : GameColors.colors = GameColors.colors.GAIA

var tier1 := 5
var tier2 := 80
var tier3 := 400
var tier4 := 4096

@onready var nodes : Array = get_parent().getAllNodes()
var myNodes := []

func _ready() -> void:
	pass


func chooseAction() -> void:
	for node : GameNode in getUnUpgraded():
		if node.unitAmounts[self.color] > 500:
			buyBuilding(node, GameTypes.factory)
	if randf() > 0.7:
		var targets = getEnemyNodes()
		targets.append_array(getUnUpgraded())
		var target = targets.pick_random()
		if target == null: return
		sendPayload(getMyNodes(), target, 99999)


func getMyNodes() -> Array:
	var myNodes := []
	for node : GameNode in nodes:
		if node.color == self.color: myNodes.append(node)
	
	return myNodes

func getUnUpgraded() -> Array:
	var a := []
	for node : GameNode in getMyNodes():
		if node.type == GameTypes.none:
			a.append(node)
	
	return a

func getEnemyNodes() -> Array:
	var enemyNodes := {} # GameNode -> 0
	for node : GameNode in getMyNodes():
		for frienemy : GameNode in node.neighbors:
			if frienemy.color != self.color:
				enemyNodes[frienemy] = 0
	
	return enemyNodes.keys()

# When player wants to send payload, send it
func sendPayload(from : Array, to : GameNode, amount : int):
	if to == null or from.size() == 0:
		return
	
	get_parent().orderSendPayload(self.color, from, to, amount)


func buyBuilding(target : GameNode, type : GameTypes.buildingType) -> void:
	get_parent().orderBuyBuilding(self.color, target, type)
