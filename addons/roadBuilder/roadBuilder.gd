@tool
extends EditorPlugin

func _process(delta):
	if Input.is_action_just_pressed("ui_home"):
		var editor = get_editor_interface()
		var nodes = editor.get_selection().get_selected_nodes()
		var node1 = nodes[0]
		var node2 = nodes[1]
		
		var road = Road.new()
		
		var parent = node2
		
		road.name = "road"
		road.node1 = node1
		road.node2 = node2
		parent.add_child(road)
		road.set_owner(parent)
		
		print(road.owner)
		print("Created road successfully")
