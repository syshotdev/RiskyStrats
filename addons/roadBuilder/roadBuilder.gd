@tool
extends EditorPlugin


func _enter_tree():
	pass

func _exit_tree():
	pass


func _unhandled_key_input(event):
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_KP_ADD:
		var selectedNodes = get_editor_interface().get_selection().get_selected_nodes()
		var nodes = getNodes(selectedNodes)
		if (nodes.size() < 2):
			return
		var node1 := nodes.get(0) as GameNode
		var node2 := nodes.get(1) as GameNode
		var roadScene = ResourceLoader.load("res://Objects/Road/road.tscn")
		var road := roadScene.instantiate() as Road
		if road == null:
			return
		var topParent = get_tree().edited_scene_root
		var roadTreeDestination : Node = topParent#topParent.find_child("Roads") if topParent.find_child("Roads") != null else topParent
		print("Road tree destination: " + str(roadTreeDestination))
		roadTreeDestination.add_child(road)
		road.set_owner(roadTreeDestination)
		
		road.node1 = node1
		road.node2 = node2
		road.global_position = node1.global_position.lerp(node2.global_position, 0.5)

		
		print("Set road's nodes to: ", node1, ", ", node2)
	
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_KP_SUBTRACT:
		var nodeScene = ResourceLoader.load("res://Objects/GameNode/node.tscn")
		var node := nodeScene.instantiate() as GameNode
		var root := get_tree().edited_scene_root
		root.add_child(node)
		node.set_owner(root)


func getRoad(objects : Array) -> Road:
	for object in objects:
		if object is Road:
			return object
	
	return null


func getNodes(objects : Array) -> Array:
	var nodes : Array[GameNode]
	
	for object in objects:
		if object is GameNode:
			nodes.append(object)
	
	return nodes
