# This is more of an orchestrator class
# Sets up map, player, camera, default values, network, and connections between nodes
# Performs the server-side checks for commands

extends Node2D

@onready var map : Map = $TestMap

func _process(delta: float) -> void:
	map.tick(delta)

func changeMap(newMap : Map):
	map = newMap.duplicate()
	map.loadMap(newMap)

func orderSendPayload(
	player : Player, 
	nodes : Array[GameNode], 
	target : GameNode, 
	amount : int
) -> void:
	# Pass along the request to the map
	# Map deals with literal values to make implementation easier :)
	if player == null or target == null: return
	map.orderSendPayload(nodes, target, Unit.new(player.color, amount))

func orderBuyBuilding(
	player : Player, 
	target : GameNode, 
	type : GameTypes.buildingType
) -> void:
	if player == null or target == null: return
	if player.color != target.color: return
	var success := map.orderBuyBuilding(target, type)
	if success:
		player.buyMenuOff()
