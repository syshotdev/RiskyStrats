extends Camera2D

var edgeMargin := 5
var cameraSpeed := 1000.0
var viewportSize := Vector2(1980, 1080)
var zoomSpeed := 20.0
var zoomConvergence := zoom
var zoomTarget := get_screen_center_position()

func _ready() -> void:
	pass

func _process(delta : float) -> void:
	processZoom(delta)
	processPan(delta)
	processMousePan(delta)
	processClickAndDrag()

func processZoom(delta : float):
	if Input.is_action_just_pressed("zoom_in"):
		if (zoom.x > 4):
			return
		zoomConvergence *= 1.2
		position -= zoomPanAmount()
	if Input.is_action_just_pressed("zoom_out"):
		if (zoom.x < 1):
			return
		zoomConvergence /= 1.2
		position -= zoomPanAmount()
	
	zoom = zoom.slerp(zoomConvergence, zoomSpeed * delta)



# TODO: Rework this so it zooms with respect to a point. This is kinda clunky
func zoomPanAmount() -> Vector2:
	return clamp((get_screen_center_position() - get_global_mouse_position()), Vector2(-100, -100), Vector2(100, 100)) * (Vector2(1, 1) - zoom / zoomConvergence)


func processPan(delta : float):
	var moveAmount := Vector2.ZERO
	if Input.is_action_pressed("left"):
		moveAmount.x -= 1
	if Input.is_action_pressed("right"):
		moveAmount.x += 1
	if Input.is_action_pressed("up"):
		moveAmount.y -= 1
	if Input.is_action_pressed("down"):
		moveAmount.y += 1
	
	position += moveAmount.normalized() * delta * cameraSpeed * (1/zoom.x)

func processMousePan(delta : float):
	var mousePosition = get_viewport().get_mouse_position()
	var moveAmount := Vector2.ZERO
	if mousePosition.x <= edgeMargin:
		moveAmount.x -= 1
	elif mousePosition.x >= viewportSize.x - edgeMargin:
		moveAmount.x += 1
	
	if mousePosition.y <= edgeMargin:
		moveAmount.y -= 1
	elif mousePosition.y >= viewportSize.y - edgeMargin:
		moveAmount.y += 1
	
	position += moveAmount.normalized() * delta * cameraSpeed * (1/zoom.x)

func processClickAndDrag():
	pass
