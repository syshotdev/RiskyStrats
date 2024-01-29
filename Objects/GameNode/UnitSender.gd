extends Node
class_name UnitSender

var neigborRoads : Dictionary = {} # Key node, value road

# Adds a neighbor and associates that neighbor with the road.
func associateRoadWithNode(neigbor : GameNode, road : Road):
	# To get the road from the neigbor
	neigborRoads[neigbor] = road

# Sends a unit to the next road based on the route
func sendRoadUnit(roadUnit : RoadUnit):
	var road = getRoadToNode(roadUnit.route[0])
	
	# Get rid of first destination to mark that we've been to this node
	roadUnit.route.remove_at(0)
	# If road.node1 == self, that means we are node1. We should then send to node2.
	roadUnit.toSecondNode = road.node1 == get_parent()
	
	# Forward unit, don't queue_free() it
	road.addUnitToRoad(roadUnit)

# From this node to the node specified, which road is it?
func getRoadToNode(node : GameNode) -> Road:
	return neigborRoads[node]
