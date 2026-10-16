extends Node2D
@onready var character: CharacterBody2D = $Character
@onready var hud: CanvasLayer = $HUD
@onready var bat: CharacterBody2D = $Bat
@onready var music: AudioStreamPlayer = $AudioStreamPlayer
@onready var ground_enemy: CharacterBody2D = $GroundEnemy


func _ready() -> void:
	music.play()
	hud.death.connect(character.died)
	bat.kill_player.connect(hud.damage)
	ground_enemy.kill_player.connect(hud.damage)
	character.player_damaged.connect(hud.damage)


func _on_character_player_died() -> void:
	get_tree().change_scene_to_file("res://Scenes/deathscreen.tscn")
