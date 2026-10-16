extends Control
@onready var death: AudioStreamPlayer2D = $death

# very rushed deathscreen
func _ready() -> void:
	death.play()

func _on_button_pressed() -> void:
	get_tree().quit()
