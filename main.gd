# This is more of an orchestrator class
# Sets up map, player, camera, default values, network, and connections between nodes
# Performs the server-side checks for commands

extends Node2D

@export var player : Player
@export var map : Map

func _process(delta: float) -> void:
	map.tick(delta)

func changeMap(newMap : Map):
	map = newMap.duplicate()
	map.loadMap(newMap)

func orderSendPayload(
	color : GameColors.colors, 
	nodes : Array, 
	target : GameNode, 
	amount : int
) -> void:
	# Pass along the request to the map
	# Map deals with literal values to make implementation easier :)
	if target == null: return
	if nodes == null or nodes.size() == 0: return
	map.orderSendPayload(nodes, target, Unit.new(color, amount))

func orderBuyBuilding(
	color : GameColors.colors,
	target : GameNode, 
	type : GameTypes.buildingType
) -> void:
	if target == null: return
	if color != target.color: return
	var success := map.orderBuyBuilding(target, type)
	if success and player.color == color:
		player.buyMenuOff()


func getAllNodes() -> Array:
	return map.nodes
