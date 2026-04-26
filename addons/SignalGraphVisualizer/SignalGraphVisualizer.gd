class_name SignalGraphVisualizer
extends Window

# LITE VERSION — Full version adds a live filter bar (type to isolate specific
# nodes/signals by name across large scenes) and a click-to-inspect panel
# (click any card to see its full signal list, node path, and connection
# details in a pinned side panel without reading the Output log).
# Full version: https://nullstateassets.itch.io

# ============================================================
# SIGNAL GRAPH VISUALIZER
# Scans the active scene tree at runtime and renders a live,
# scrollable graph of every signal connection. Eliminates the
# "where is that signal connected?" debugging spiral entirely.
# Attach to any node; it spawns its own Window so it never
# pollutes your scene hierarchy visually.
# ============================================================

@export_category("Graph Window")
@export_group("Dimensions")
@export var window_title: String = "Signal Graph Visualizer"
@export var initial_window_size: Vector2i = Vector2i(1100, 720)
@export var min_window_size: Vector2i = Vector2i(640, 400)

@export_group("Startup Behavior")
@export var auto_open_on_ready: bool = true
@export var scan_on_open: bool = true
## Root path to scan. Leave "/" to scan the entire scene tree.
@export var scan_root_path: NodePath = NodePath("/root")

@export_category("Node Cards")
@export_group("Layout")
@export var card_width: float = 220.0
@export var card_min_height: float = 60.0
@export var card_padding: Vector2 = Vector2(14.0, 10.0)
@export var card_horizontal_gap: float = 80.0
@export var card_vertical_gap: float = 24.0
## How many node cards per column before wrapping to a new column.
@export var cards_per_column: int = 6

@export_group("Card Colors")
@export var card_bg_color: Color = Color("1e2230")
@export var card_border_color: Color = Color("3a3f55")
@export var card_header_color: Color = Color("2a2f45")
@export var card_selected_border_color: Color = Color("f0c040")
@export var card_hover_border_color: Color = Color("6a7aaa")

@export_group("Card Typography")
@export var node_name_font_size: int = 13
@export var signal_font_size: int = 11
@export var node_type_font_size: int = 10
@export var node_name_color: Color = Color("e8eaf0")
@export var signal_emit_color: Color = Color("f08060")
@export var signal_recv_color: Color = Color("60c0f0")
@export var node_type_color: Color = Color("7a8aaa")

@export_category("Connection Lines")
@export_group("Appearance")
@export var line_base_color: Color = Color("c06030", 0.85)
@export var line_hover_color: Color = Color("f0c040", 1.0)
@export var line_selected_color: Color = Color("ffffff", 1.0)
@export var line_width: float = 2.0
@export var line_hover_width: float = 3.5
## Bezier curve tangent strength as a fraction of horizontal distance.
## Higher values produce more pronounced S-curves between distant cards.
@export_range(0.1, 1.5, 0.05) var bezier_tangent_strength: float = 0.55
@export var bezier_steps: int = 48

@export_category("Interaction")
@export_group("Canvas Pan & Zoom")
@export var zoom_min: float = 0.25
@export var zoom_max: float = 3.0
@export_range(0.05, 0.3, 0.01) var zoom_step: float = 0.1
@export var pan_button: MouseButton = MOUSE_BUTTON_MIDDLE
@export var pan_sensitivity: float = 1.0

@export_group("Selection & Highlight")
## Opacity multiplier applied to cards/lines NOT related to the selection.
@export_range(0.05, 1.0, 0.05) var dim_opacity: float = 0.18
@export var highlight_connected_cards: bool = true

@export_category("Toolbar")
@export_group("Refresh")
@export var show_refresh_button: bool = true
@export var refresh_button_label: String = "  ↺  Refresh  "
@export var show_reset_view_button: bool = true
@export var reset_view_button_label: String = "  ⌖  Reset View  "

@export_category("Debug")
@export var print_scan_summary: bool = false

# ── Internal state ────────────────────────────────────────────────────────────

# Represents one scanned node that has at least one signal involvement.
class NodeCard:
	var node_path: NodePath
	var node_name: String
	var node_type: String
	var rect: Rect2          # canvas-space position & size
	var emitted_signals: Array[String] = []   # signals this node emits to others
	var received_signals: Array[String] = []  # signals this node receives

# Represents one resolved signal connection between two cards.
class ConnectionEdge:
	var from_card_index: int
	var to_card_index: int
	var signal_name: String
	var method_name: String
	var from_port: Vector2   # canvas-space anchor on emitter card
	var to_port: Vector2     # canvas-space anchor on receiver card

var _cards: Array[NodeCard] = []
var _edges: Array[ConnectionEdge] = []

# Canvas transform state — all drawing is offset+scaled through these.
var _canvas_offset: Vector2 = Vector2.ZERO
var _canvas_zoom: float = 1.0

# Interaction tracking
var _is_panning: bool = false
var _pan_start_mouse: Vector2 = Vector2.ZERO
var _pan_start_offset: Vector2 = Vector2.ZERO
var _hovered_card_index: int = -1
var _selected_card_index: int = -1
var _hovered_edge_index: int = -1

# UI node references built in _build_ui()
var _canvas: Control
var _toolbar: HBoxContainer
var _status_label: Label

# ── Lifecycle ─────────────────────────────────────────────────────────────────

func _ready() -> void:
	_configure_window()
	_build_ui()
	if auto_open_on_ready:
		show()
		if scan_on_open:
			_run_scan()

func _configure_window() -> void:
	title = window_title
	size = initial_window_size
	min_size = min_window_size
	# Unparent from scene flow so it floats independently over the game viewport.
	wrap_controls = true
	close_requested.connect(_on_close_requested)

# ── UI Construction ───────────────────────────────────────────────────────────

func _build_ui() -> void:
	var root_vbox := VBoxContainer.new()
	root_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root_vbox)

	_build_toolbar(root_vbox)

	var canvas_panel := Panel.new()
	canvas_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	canvas_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	canvas_panel.clip_contents = true
	# Dark canvas background distinct from card color so cards pop visually.
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("13151f")
	canvas_panel.add_theme_stylebox_override("panel", panel_style)
	root_vbox.add_child(canvas_panel)

	_canvas = Control.new()
	_canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_canvas.mouse_filter = Control.MOUSE_FILTER_PASS
	canvas_panel.add_child(_canvas)

	_canvas.draw.connect(_on_canvas_draw)
	_canvas.gui_input.connect(_on_canvas_input)
	_canvas.mouse_exited.connect(_on_canvas_mouse_exited)

	var status_bar := HBoxContainer.new()
	root_vbox.add_child(status_bar)
	_status_label = Label.new()
	_status_label.text = "No scan yet. Press Refresh."
	_status_label.add_theme_font_size_override("font_size", 11)
	_status_label.add_theme_color_override("font_color", Color("6a7aaa"))
	var status_style := StyleBoxFlat.new()
	status_style.bg_color = Color("0d0f18")
	status_style.content_margin_left = 8.0
	status_style.content_margin_top = 3.0
	status_style.content_margin_bottom = 3.0
	status_bar.add_theme_constant_override("separation", 0)
	_status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_bar.add_child(_status_label)

func _build_toolbar(parent: Control) -> void:
	_toolbar = HBoxContainer.new()
	var tb_style := StyleBoxFlat.new()
	tb_style.bg_color = Color("181b28")
	tb_style.content_margin_left = 8.0
	tb_style.content_margin_right = 8.0
	tb_style.content_margin_top = 6.0
	tb_style.content_margin_bottom = 6.0
	_toolbar.add_theme_stylebox_override("panel", tb_style)
	parent.add_child(_toolbar)

	if show_refresh_button:
		var btn := _make_toolbar_button(refresh_button_label)
		btn.pressed.connect(_run_scan)
		_toolbar.add_child(btn)

	if show_reset_view_button:
		var btn := _make_toolbar_button(reset_view_button_label)
		btn.pressed.connect(_reset_view)
		_toolbar.add_child(btn)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_toolbar.add_child(spacer)

func _make_toolbar_button(label_text: String) -> Button:
	var btn := Button.new()
	btn.text = label_text
	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = Color("2a2f45")
	normal_style.corner_radius_top_left = 4
	normal_style.corner_radius_top_right = 4
	normal_style.corner_radius_bottom_left = 4
	normal_style.corner_radius_bottom_right = 4
	normal_style.content_margin_left = 10.0
	normal_style.content_margin_right = 10.0
	normal_style.content_margin_top = 4.0
	normal_style.content_margin_bottom = 4.0
	var hover_style := normal_style.duplicate()
	hover_style.bg_color = Color("3a4060")
	btn.add_theme_stylebox_override("normal", normal_style)
	btn.add_theme_stylebox_override("hover", hover_style)
	btn.add_theme_stylebox_override("pressed", hover_style)
	btn.add_theme_stylebox_override("focus", normal_style)
	btn.add_theme_color_override("font_color", Color("c8d0e8"))
	btn.add_theme_font_size_override("font_size", 12)
	return btn

# ── Scanning ──────────────────────────────────────────────────────────────────

func _run_scan() -> void:
	_cards.clear()
	_edges.clear()
	_selected_card_index = -1
	_hovered_card_index = -1
	_hovered_edge_index = -1

	var scan_root: Node = get_node_or_null(scan_root_path)
	if scan_root == null:
		# Fallback: if the configured path is unreachable (e.g. in editor preview),
		# scan from this node's own scene root so the tool is never completely blind.
		scan_root = get_tree().root

	# First pass: collect every node that participates in at least one connection.
	var participating: Dictionary = {}  # NodePath -> NodeCard
	_collect_connections(scan_root, participating)

	_cards = []
	for card in participating.values():
		_cards.append(card)

	# Sort alphabetically so layout is deterministic across refreshes.
	_cards.sort_custom(func(a: NodeCard, b: NodeCard) -> bool:
		return str(a.node_path) < str(b.node_path)
	)

	# Build a fast lookup from NodePath → card index.
	var card_index_map: Dictionary = {}
	for i in _cards.size():
		card_index_map[_cards[i].node_path] = i

	# Layout: arrange cards into columns of `cards_per_column` rows.
	var col_heights: Array[float] = []
	for i in _cards.size():
		var col: int = i / cards_per_column
		while col_heights.size() <= col:
			col_heights.append(0.0)
		var card: NodeCard = _cards[i]
		var row_count: int = card.emitted_signals.size() + card.received_signals.size()
		var card_h: float = card_min_height + float(row_count) * float(signal_font_size + 4) + card_padding.y * 2.0
		card.rect = Rect2(float(col) * (card_width + card_horizontal_gap), col_heights[col], card_width, card_h)
		col_heights[col] += card_h + card_vertical_gap

	# Build edges with correct card indices.
	_edges.clear()
	_build_edges(scan_root, card_index_map)
	_update_edge_ports()

	if print_scan_summary:
		print("[SignalGraphVisualizer] Scanned: %d nodes, %d connections" % [_cards.size(), _edges.size()])

	_status_label.text = "  %d nodes  ·  %d connections" % [_cards.size(), _edges.size()]
	_reset_view()


func _collect_connections(node: Node, participating: Dictionary) -> void:
	for sig_info in node.get_signal_list():
		var sig_name: String = sig_info["name"]
		for conn in node.get_signal_connection_list(sig_name):
			var receiver_obj: Object = (conn["callable"] as Callable).get_object()
			if not (receiver_obj is Node):
				continue
			var receiver_node: Node = receiver_obj as Node
			var emitter_path: NodePath = node.get_path()
			var receiver_path: NodePath = receiver_node.get_path()

			if not participating.has(emitter_path):
				var c := NodeCard.new()
				c.node_path = emitter_path
				c.node_name = node.name
				c.node_type = node.get_class()
				participating[emitter_path] = c
			var ec: NodeCard = participating[emitter_path]
			if not sig_name in ec.emitted_signals:
				ec.emitted_signals.append(sig_name)

			if not participating.has(receiver_path):
				var c := NodeCard.new()
				c.node_path = receiver_path
				c.node_name = receiver_node.name
				c.node_type = receiver_node.get_class()
				participating[receiver_path] = c
			var rc: NodeCard = participating[receiver_path]
			if not sig_name in rc.received_signals:
				rc.received_signals.append(sig_name)

	for child in node.get_children():
		_collect_connections(child, participating)


func _build_edges(node: Node, card_index_map: Dictionary) -> void:
	for sig_info in node.get_signal_list():
		var sig_name: String = sig_info["name"]
		for conn in node.get_signal_connection_list(sig_name):
			var callable: Callable = conn["callable"]
			var receiver_obj: Object = callable.get_object()
			if not (receiver_obj is Node):
				continue
			var emitter_path: NodePath = node.get_path()
			var receiver_path: NodePath = (receiver_obj as Node).get_path()
			if not card_index_map.has(emitter_path) or not card_index_map.has(receiver_path):
				continue
			var edge := ConnectionEdge.new()
			edge.from_card_index = card_index_map[emitter_path]
			edge.to_card_index = card_index_map[receiver_path]
			edge.signal_name = sig_name
			edge.method_name = callable.get_method()
			_edges.append(edge)

	for child in node.get_children():
		_build_edges(child, card_index_map)


func _update_edge_ports() -> void:
	for edge in _edges:
		var fc: NodeCard = _cards[edge.from_card_index]
		var tc: NodeCard = _cards[edge.to_card_index]
		edge.from_port = fc.rect.position + Vector2(fc.rect.size.x, fc.rect.size.y * 0.5)
		edge.to_port   = tc.rect.position + Vector2(0.0,           tc.rect.size.y * 0.5)


# ── Signal callbacks ──────────────────────────────────────────────────────────

func _on_close_requested() -> void:
	hide()


func _reset_view() -> void:
	_canvas_zoom = 1.0
	_canvas_offset = Vector2(40.0, 40.0)
	if _canvas != null:
		_canvas.queue_redraw()


func _on_canvas_mouse_exited() -> void:
	if _hovered_card_index != -1 or _hovered_edge_index != -1 or _is_panning:
		_hovered_card_index = -1
		_hovered_edge_index = -1
		_is_panning = false
		_canvas.queue_redraw()


func _on_canvas_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == pan_button:
			_is_panning = mb.pressed
			if mb.pressed:
				_pan_start_mouse  = mb.position
				_pan_start_offset = _canvas_offset
		elif mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed:
			_zoom_at(mb.position, zoom_step)
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed:
			_zoom_at(mb.position, -zoom_step)
		elif mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			_handle_left_click(mb.position)
	elif event is InputEventMouseMotion:
		var mm := event as InputEventMouseMotion
		if _is_panning:
			_canvas_offset = _pan_start_offset + (mm.position - _pan_start_mouse) * pan_sensitivity
			_canvas.queue_redraw()
		else:
			_update_hover(mm.position)


# ── Interaction helpers ───────────────────────────────────────────────────────

func _zoom_at(mouse_pos: Vector2, delta: float) -> void:
	var old_zoom: float = _canvas_zoom
	_canvas_zoom = clamp(_canvas_zoom + delta, zoom_min, zoom_max)
	_canvas_offset = mouse_pos - (mouse_pos - _canvas_offset) * (_canvas_zoom / old_zoom)
	_canvas.queue_redraw()


func _handle_left_click(mouse_pos: Vector2) -> void:
	var canvas_pos: Vector2 = (mouse_pos - _canvas_offset) / _canvas_zoom
	for i in _cards.size():
		var card: NodeCard = _cards[i]
		if card.rect.has_point(canvas_pos):
			_selected_card_index = -1 if _selected_card_index == i else i
			_canvas.queue_redraw()
			return
	_selected_card_index = -1
	_canvas.queue_redraw()


func _update_hover(mouse_pos: Vector2) -> void:
	var canvas_pos: Vector2 = (mouse_pos - _canvas_offset) / _canvas_zoom

	var new_hovered_card: int = -1
	for i in _cards.size():
		if _cards[i].rect.has_point(canvas_pos):
			new_hovered_card = i
			break

	var new_hovered_edge: int = -1
	if new_hovered_card == -1:
		for i in _edges.size():
			if _point_near_bezier(canvas_pos, _edges[i], 8.0 / _canvas_zoom):
				new_hovered_edge = i
				break

	if new_hovered_card != _hovered_card_index or new_hovered_edge != _hovered_edge_index:
		_hovered_card_index = new_hovered_card
		_hovered_edge_index = new_hovered_edge
		_canvas.queue_redraw()


func _point_near_bezier(pt: Vector2, edge: ConnectionEdge, threshold: float) -> bool:
	var p0: Vector2 = edge.from_port
	var p3: Vector2 = edge.to_port
	var tx: float = abs(p3.x - p0.x) * bezier_tangent_strength
	var p1: Vector2 = p0 + Vector2(tx, 0.0)
	var p2: Vector2 = p3 - Vector2(tx, 0.0)
	for step in range(bezier_steps + 1):
		if pt.distance_to(_bezier_point(p0, p1, p2, p3, float(step) / float(bezier_steps))) <= threshold:
			return true
	return false


func _bezier_point(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float) -> Vector2:
	var u: float = 1.0 - t
	return u*u*u*p0 + 3.0*u*u*t*p1 + 3.0*u*t*t*p2 + t*t*t*p3


# ── Canvas drawing ────────────────────────────────────────────────────────────

func _on_canvas_draw() -> void:
	if _cards.is_empty():
		return

	# Compute which cards/edges are highlighted when a card is selected.
	var hi_cards: Array[int] = []
	var hi_edges: Array[int] = []
	if _selected_card_index >= 0:
		hi_cards.append(_selected_card_index)
		for i in _edges.size():
			var edge: ConnectionEdge = _edges[i]
			if edge.from_card_index == _selected_card_index or edge.to_card_index == _selected_card_index:
				hi_edges.append(i)
				if not edge.from_card_index in hi_cards:
					hi_cards.append(edge.from_card_index)
				if not edge.to_card_index in hi_cards:
					hi_cards.append(edge.to_card_index)

	# ── Edges ─────────────────────────────────────────────────────────────────
	for i in _edges.size():
		var edge: ConnectionEdge = _edges[i]

		var dimmed: bool = _selected_card_index >= 0 and not (i in hi_edges)
		var col: Color
		if i == _hovered_edge_index:
			col = line_hover_color
		elif not dimmed and _selected_card_index >= 0:
			col = line_selected_color
		else:
			col = line_base_color
		if dimmed:
			col.a *= dim_opacity

		var lw: float = (line_hover_width if i == _hovered_edge_index else line_width) * _canvas_zoom

		var p0: Vector2 = _canvas_offset + edge.from_port * _canvas_zoom
		var p3: Vector2 = _canvas_offset + edge.to_port   * _canvas_zoom
		var tx: float   = abs(p3.x - p0.x) * bezier_tangent_strength
		var p1: Vector2 = p0 + Vector2(tx, 0.0)
		var p2: Vector2 = p3 - Vector2(tx, 0.0)

		var prev_pt: Vector2 = p0
		for step in range(1, bezier_steps + 1):
			var cur_pt: Vector2 = _bezier_point(p0, p1, p2, p3, float(step) / float(bezier_steps))
			_canvas.draw_line(prev_pt, cur_pt, col, lw, true)
			prev_pt = cur_pt

	# ── Cards ─────────────────────────────────────────────────────────────────
	var font: Font = ThemeDB.fallback_font
	for i in _cards.size():
		var card: NodeCard = _cards[i]

		var is_selected: bool = i == _selected_card_index
		var is_hovered:  bool = i == _hovered_card_index
		var is_dimmed:   bool = _selected_card_index >= 0 and not (i in hi_cards)
		var alpha: float = dim_opacity if is_dimmed else 1.0

		var rp: Vector2 = _canvas_offset + card.rect.position * _canvas_zoom
		var rs: Vector2 = card.rect.size * _canvas_zoom
		var r:  Rect2   = Rect2(rp, rs)

		var bg: Color = card_bg_color; bg.a *= alpha
		_canvas.draw_rect(r, bg, true)

		var header_h: float = (float(node_name_font_size) + card_padding.y * 2.0) * _canvas_zoom
		var hdr: Color = card_header_color; hdr.a *= alpha
		_canvas.draw_rect(Rect2(rp, Vector2(rs.x, header_h)), hdr, true)

		var border: Color
		if is_selected:    border = card_selected_border_color
		elif is_hovered:   border = card_hover_border_color
		else:              border = card_border_color
		border.a *= alpha
		_canvas.draw_rect(r, border, false, 1.5)

		var fsz_name: int = int(float(node_name_font_size) * _canvas_zoom)
		var fsz_sig:  int = int(float(signal_font_size)    * _canvas_zoom)
		var fsz_type: int = int(float(node_type_font_size) * _canvas_zoom)
		var pad_x: float = card_padding.x * _canvas_zoom
		var pad_y: float = card_padding.y * _canvas_zoom

		if fsz_name >= 5:
			var nc: Color = node_name_color; nc.a *= alpha
			_canvas.draw_string(font, rp + Vector2(pad_x, pad_y + float(fsz_name)),
				card.node_name, HORIZONTAL_ALIGNMENT_LEFT, rs.x - pad_x * 2.0, fsz_name, nc)

		if fsz_type >= 5:
			var tc: Color = node_type_color; tc.a *= alpha
			_canvas.draw_string(font, rp + Vector2(rs.x - pad_x, pad_y + float(fsz_type)),
				card.node_type, HORIZONTAL_ALIGNMENT_RIGHT, -1, fsz_type, tc)

		if fsz_sig >= 5:
			var y: float = header_h + pad_y
			for sig in card.emitted_signals:
				var sc: Color = signal_emit_color; sc.a *= alpha
				_canvas.draw_string(font, rp + Vector2(pad_x, y + float(fsz_sig)),
					"\u2192 " + sig, HORIZONTAL_ALIGNMENT_LEFT, rs.x - pad_x * 2.0, fsz_sig, sc)
				y += float(fsz_sig + 4) * _canvas_zoom
			for sig in card.received_signals:
				var rc: Color = signal_recv_color; rc.a *= alpha
				_canvas.draw_string(font, rp + Vector2(pad_x, y + float(fsz_sig)),
					"\u2190 " + sig, HORIZONTAL_ALIGNMENT_LEFT, rs.x - pad_x * 2.0, fsz_sig, rc)
				y += float(fsz_sig + 4) * _canvas_zoom
