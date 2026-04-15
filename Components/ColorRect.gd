extends ColorRect



func setColor(newColor : Color):
	color = newColor

func colorChanged(newColor):
	setColor(newColor)
