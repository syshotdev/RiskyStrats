@tool
extends EditorPlugin

func _enter_tree():
	pass

func _exit_tree():
	pass


func _unhandled_key_input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_KP_ADD:
		var selected_nodes = get_editor_interface().get_selection().get_selected_nodes()
		var second_node = selected_nodes[1]
		addColorRectToNode(second_node)


func addColorRectToNode(node : Node):
	var interface = get_editor_interface()
	var colorRect := ColorRect.new()
	colorRect.size = Vector2(100, 100)# Set a default size
	colorRect.color = Color(1, 0, 0, 1)# Set a default color (Red)
	colorRect.visible = true# Ensure it's visible
	colorRect.owner = node
	
	# Undo/Redo functionality
	var undo_redo = get_undo_redo()
	undo_redo.create_action("Add ColorRect")
	undo_redo.add_do_method(node, "add_child", colorRect)
	undo_redo.add_undo_method(node, "remove_child", colorRect)
	undo_redo.commit_action()
	
	interface.get_selection().get_selected_nodes().clear()
	print(interface.get_selection().get_selected_nodes())
	interface.get_selection().get_selected_nodes().append(colorRect)
	print(interface.get_selection().get_selected_nodes())
	
	# Debugging
	print("Added ColorRect to: ", node.name)
