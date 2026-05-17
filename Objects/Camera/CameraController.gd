extends Camera2D

var edgeMargin := 5
var cameraSpeed := 500.0
var viewportSize := get_viewport_rect().size

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	processZoom()
	processPan(delta)
	processMousePan(delta)
	processClickAndDrag()

func processZoom():
	if Input.is_action_just_pressed("zoom_in"):
		if zoom.x < 4:
			var mousePosition := get_viewport().get_mouse_position()
			var preZoomValue := zoom
			zoom = zoom + Vector2(0.25, 0.25)
			# Position is based on where you scroll on the screen
			position += (mousePosition - position) * (Vector2(1, 1) - preZoomValue / zoom)
	if Input.is_action_just_pressed("zoom_out"):
		if zoom.x > 1:
			var mousePosition := get_viewport().get_mouse_position()
			var preZoomValue := zoom
			zoom = zoom - Vector2(0.25, 0.25)
			position += (mousePosition - position) * (Vector2(1, 1) - preZoomValue / zoom)


var moveAmount := Vector2.ZERO
func processPan(delta : float):
	Vector2.ZERO
	if Input.is_action_pressed("left"):
		moveAmount.x -= 1
	if Input.is_action_pressed("right"):
		moveAmount.x += 1
	if Input.is_action_pressed("up"):
		moveAmount.y -= 1
	if Input.is_action_pressed("down"):
		moveAmount.y += 1
	
	position += moveAmount * delta * cameraSpeed * (1/zoom.x)

func processMousePan(delta : float):
	var moveAmount := Vector2.ZERO
	if Input.is_action_pressed("left"):
		position.x -= cameraSpeed * delta
	if Input.is_action_pressed("right"):
		position.x += cameraSpeed * delta
	if Input.is_action_pressed("up"):
		position.y -= cameraSpeed * delta
	if Input.is_action_pressed("down"):
		position.y += cameraSpeed * delta

func processClickAndDrag():
	pass
