@tool
extends Node2D

var globalDelta : float = 0

func _process(delta):
	if(globalDelta > 1):
		globalDelta = 0
		print("hi")
	globalDelta += delta

func _input(event):
	print("yep working")
