class_name SelectionTool
extends CanvasTool

const MAX_FLOAT := 2147483646.0
const MIN_FLOAT := -2147483646.0
const META_OFFSET := "offset"
const GROUP_SELECTED_NODES := "selected_nodes" # selected nodes
const GROUP_NODES_IN_SELECTION_RECTANGLE := "nodes_in_selection_rectangle" # nodes that are in selection rectangle but not commit (i.e. the user is still selecting)
const GROUP_MARKED_FOR_DESELECTION := "nodes_marked_for_deselection" # nodes that need to be deslected once LMB is released
const GROUP_COPIED_NODES := "nodes_copied"

# -------------------------------------------------------------------------------------------------
enum State {
	NONE,
	SELECTING,
	MOVING
}

# -------------------------------------------------------------------------------------------------
@export var selection_rectangle_path: NodePath
var _selection_rectangle: SelectionRectangle
var _state := State.NONE
var _selecting_start_pos: Vector2 = Vector2.ZERO
var _selecting_end_pos: Vector2 = Vector2.ZERO
var _multi_selecting: bool
var _mouse_moved_during_pressed := false
var _node_positions_before_move := {} # GameNode -> Vector2
var _bounding_box_cache := {} # GameNode -> Rect2

# ------------------------------------------------------------------------------------------------
func _ready() -> void:
	super()
	_selection_rectangle = get_node(selection_rectangle_path)

# ------------------------------------------------------------------------------------------------
func tool_event(event: InputEvent) -> void:
	if event is InputEventMouseButton && !disable_node:
		if event.button_index == MOUSE_BUTTON_LEFT:
			# LMB down - decide if we should select/multiselect or move the selection
			if event.pressed:
				_selecting_start_pos = get_global_mouse_position()
				if event.shift_pressed:
					_state = State.SELECTING
					_multi_selecting = true
					_build_bounding_boxes()
				elif get_selected_nodes().size() == 0:
					_state = State.SELECTING
					_multi_selecting = false
					_build_bounding_boxes()
				else:
					_state = State.MOVING
					_mouse_moved_during_pressed = false
			# LMB up - stop selection or movement
			else:
				if _state == State.SELECTING:
					_state = State.NONE
					_selection_rectangle.reset()
					_selection_rectangle.queue_redraw()
					_commit_nodes_under_selection_rectangle()
					_deselect_marked_nodes()
						
		# RMB down - just deselect
		elif event.button_index == MOUSE_BUTTON_RIGHT && event.pressed && _state == State.NONE:
			deselect_all_nodes()
	
	# Mouse movement: move the selection
	elif event is InputEventMouseMotion:
		var event_pos := get_global_mouse_position()
		if _state == State.SELECTING:
			_selecting_end_pos = event_pos
			compute_selection(_selecting_start_pos, _selecting_end_pos)
			_selection_rectangle.start_position = _selecting_start_pos
			_selection_rectangle.end_position = _selecting_end_pos
			_selection_rectangle.queue_redraw()

# ------------------------------------------------------------------------------------------------
func compute_selection(start_pos: Vector2, end_pos: Vector2) -> void:
	var selection_rect : Rect2 = Utils.calculate_rect(start_pos, end_pos)
	for node: GameNode in _canvas.get_nodes_in_camera_frustrum():
		var bounding_box: Rect2 = _bounding_box_cache[node]
		if selection_rect.intersects(bounding_box):
			for point: Vector2 in node.points:
				var abs_point: Vector2 = node.position + point
				if selection_rect.has_point(abs_point):
					_set_node_selected(node)
					break

# ------------------------------------------------------------------------------------------------
func _build_bounding_boxes() -> void:
	_bounding_box_cache.clear()
	_bounding_box_cache = Utils.calculte_bounding_boxes(_canvas.get_all_nodes())
	#$"../Viewport/DebugDraw".set_bounding_boxes(_bounding_box_cache.values())
	
# ------------------------------------------------------------------------------------------------
func _set_node_selected(node: GameNode) -> void:
	if node.is_in_group(GROUP_SELECTED_NODES):
		node.modulate = Color.WHITE
		node.add_to_group(GROUP_MARKED_FOR_DESELECTION)
	else:
		node.modulate = Config.DEFAULT_SELECTION_COLOR
		node.add_to_group(GROUP_NODES_IN_SELECTION_RECTANGLE)

# ------------------------------------------------------------------------------------------------
func _commit_nodes_under_selection_rectangle() -> void:
	for node: GameNode in get_tree().get_nodes_in_group(GROUP_NODES_IN_SELECTION_RECTANGLE):
		node.remove_from_group(GROUP_NODES_IN_SELECTION_RECTANGLE)
		node.add_to_group(GROUP_SELECTED_NODES)

# ------------------------------------------------------------------------------------------------
func _deselect_marked_nodes() -> void:
	for node: GameNode in get_tree().get_nodes_in_group(GROUP_MARKED_FOR_DESELECTION):
		node.remove_from_group(GROUP_MARKED_FOR_DESELECTION)
		node.remove_from_group(GROUP_SELECTED_nodeS)
		node.modulate = Color.WHITE

# ------------------------------------------------------------------------------------------------
func deselect_all_nodes() -> void:
	var selected_nodes: Array = get_selected_nodes()
	if selected_nodes.size():
		get_tree().set_group(GROUP_SELECTED_NODES, "modulate", Color.WHITE)
		get_tree().set_group(GROUP_NODES_IN_SELECTION_RECTANGLE, "modulate", Color.WHITE)
		Utils.remove_group_from_all_nodes(GROUP_SELECTED_NODES)
		Utils.remove_group_from_all_nodes(GROUP_MARKED_FOR_DESELECTION)
		Utils.remove_group_from_all_nodes(GROUP_NODES_IN_SELECTION_RECTANGLE)

# ------------------------------------------------------------------------------------------------
func is_selecting() -> bool:
	return _state == State.SELECTING

# ------------------------------------------------------------------------------------------------
func get_selected_nodes() -> Array[GameNode]:
	# Can't cast from Array[Node] to Array[Brushnode] directly (godot bug/missing feature?)
	# so let's do it per item
	var nodes: Array[GameNode]
	for node in get_tree().get_nodes_in_group(GROUP_SELECTED_NODES):
		nodes.append(node as GameNode)
	
	return nodes

# ------------------------------------------------------------------------------------------------
func reset() -> void:
	_state = State.NONE
	_selection_rectangle.reset()
	_selection_rectangle.queue_redraw()
	_commit_nodes_under_selection_rectangle()
	deselect_all_nodes()
