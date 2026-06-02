@icon("res://Assets/Icons/tools.png")
class_name CanvasTool
extends Node2D

# -------------------------------------------------------------------------------------------------
const SUBDIVISION_PERCENT := 0.16
const SUBDIVISION_THRESHHOLD := 50.0 # min length in pixels for when subdivision is required 

# -------------------------------------------------------------------------------------------------
var player: Player
var enabled := false: get = get_enabled, set = set_enabled
var performing_node := false
var disable_node := false
var panning_detected := false
var zooming_detected := false

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	player = get_parent()
	set_enabled(false)

# -------------------------------------------------------------------------------------------------
func tool_event(event: InputEvent) -> void:
	pass

# -------------------------------------------------------------------------------------------------
func _on_brush_color_changed(color: Color) -> void:
	pass

# -------------------------------------------------------------------------------------------------
func _on_panning_toggled(panning_enabled: bool) -> void:
	panning_detected = panning_enabled

# -------------------------------------------------------------------------------------------------
func _on_zooming_toggled(zooming_enabled: bool) -> void:
	zooming_detected = zooming_enabled

# -------------------------------------------------------------------------------------------------
func set_enabled(e: bool) -> void:
	enabled = e
	set_process(enabled)
	set_process_input(enabled)

# -------------------------------------------------------------------------------------------------
func get_enabled() -> bool:
	return enabled

# -------------------------------------------------------------------------------------------------
func get_current_node() -> GameNode:
	return player.currentNode
