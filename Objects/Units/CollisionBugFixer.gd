extends CollisionShape2D

# Class made because can't set collision shape radius in parent init function
func _ready():
	#shape.radius = get_parent().radius
	print("hello")
