@tool
extends EditorPlugin

func _enter_tree():
	pass

func _exit_tree():
	pass


func _unhandled_key_input(event):
	# Not key press
	if not event is InputEventKey:
		return
	
	# Not pressed
	if not event.pressed:
		return
	
	# Not keypad add
	if event.keycode != KEY_KP_ADD:
		return
	
	var selectedNodes = get_editor_interface().get_selection().get_selected_nodes()
	var road = getRoad(selectedNodes)
	
	if road == null:
		return
	
	var nodes = getNodes(selectedNodes)
	
	road.node1 = nodes[0]
	road.node2 = nodes[1]
	
	print("Set road's nodes to: ", nodes[0], ", ", nodes[1])


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
