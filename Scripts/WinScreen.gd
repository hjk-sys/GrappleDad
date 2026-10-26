extends CenterContainer


func _on_playagain_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/world.tscn")


func _on_quitgame_pressed() -> void:
	get_tree().quit()
