extends CanvasLayer

const Healthbar = preload("res://Scenes/healthbar.tscn")

@onready var healthcontainer: HBoxContainer = $HealthCont

var hearts = [1,1,1,1,1]

signal death

func _ready() -> void:
	check_health()

func check_health():
	for heart in healthcontainer.get_children():
		healthcontainer.remove_child(heart)
	for i in hearts:
		var heart = Healthbar.instantiate()
		heart.set_icon("full")
		healthcontainer.add_child(heart)
	if len(hearts) == 0:
		death.emit()

func damage():
	hearts.pop_back()
	check_health()


func _process(delta: float) -> void:
	pass
	
