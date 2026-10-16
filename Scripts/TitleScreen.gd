extends CenterContainer
@onready var startgame: Button = $VBoxContainer/startgame

func _ready():
	pass


func _on_startgame_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/world.tscn")


func _on_quitgame_pressed() -> void:
	get_tree().quit()
