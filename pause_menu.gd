extends Control

func _ready() -> void:
	resume()
	self.visible = false

func resume():
	self.visible = false
	get_tree().paused = false

func pause():
	self.visible = true
	get_tree().paused = true

func check():
	if get_tree().paused == false and Input.is_action_just_pressed("pause"):
		pause()
	elif get_tree().paused == true and Input.is_action_just_pressed("pause"):
		resume()
		

func _on_resume_pressed() -> void:
	resume()

func _process(delta: float) -> void:
	check()

func _on_quit_pressed() -> void:
	get_tree().quit()
