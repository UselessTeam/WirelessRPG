extends Camera


const V_LOOK_SENS = 1.0

func _input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.x -= event.relative.y * V_LOOK_SENS
		rotation_degrees.x = clamp(rotation_degrees.x, -90, 90)
 
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
