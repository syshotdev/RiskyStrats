@tool
extends EditorPlugin

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		var editor = get_editor_interface()
		var nodes = editor.get_selection().get_selected_nodes()
		var node1 = get_node(nodes[0])
		var node2 = get_node(nodes[1])
		var road = Road.new()
		
		get_parent().add_child(road)
		road.node1 = node1
		road.node2 = node2
		
		print("Created road successfully")
