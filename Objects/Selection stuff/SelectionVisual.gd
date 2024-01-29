extends Node2D

var shape

func _draw():
	if shape is RectangleShape2D:
		draw_rect(Rect2(position, shape.size), GameColors.selectionColor)
	if shape is CircleShape2D:
		draw_circle(position, shape.radius, GameColors.selectionColor)


func updateShape(newShape : Shape2D):
	shape = newShape
	queue_redraw()
