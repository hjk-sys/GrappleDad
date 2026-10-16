extends Camera2D
 
const DEAD_ZONE = 320

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var target = event.position - get_viewport().size * 0.135
		if target.length() < DEAD_ZONE:
			self.position = Vector2(0,0)
		else:
			self.position = target.normalized() * (target.length() - DEAD_ZONE) * 0.5
